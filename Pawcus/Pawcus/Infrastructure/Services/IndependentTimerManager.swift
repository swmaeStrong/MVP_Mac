//
//  IndependentTimerManager.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import Foundation
import Combine
import SwiftUI
import Factory
import UserNotifications

enum TimerMode: String, CaseIterable {
    case stopwatch = "stopwatch"
    case timer = "timer"
    
    var displayName: String {
        switch self {
        case .stopwatch:
            return "Stopwatch"
        case .timer:
            return "Timer"
        }
    }
    
    var icon: String {
        switch self {
        case .stopwatch:
            return "stopwatch"
        case .timer:
            return "timer"
        }
    }
}

final class IndependentTimerManager: ObservableObject {
    // 타이머 설정
    @Published var timerMode: TimerMode = .timer
    @Published var timerDurationMinutes: Int = 25 // 기본 25분
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false // 일시정지 상태
    
    // 현재 시간 (초 단위)
    @Published private(set) var currentSeconds: Int = 0
    
    // 표시 시간 (자동 업데이트를 위한 Published 프로퍼티)
    @Published private(set) var displayTimeString: String = "25:00"
    
    // 타이머 관련
    private var timer: Timer?
    
    // 로그 기록을 위한 의존성
    @Injected(\.activityLogger) private var activityLogger
    @Injected(\.transferUsageLogsUseCase) private var uploadUseCase
    private var autoSendTimer: Timer?
    
    // UserDefaults 키
    private let timerModeKey = "independentTimerMode"
    private let timerDurationKey = "independentTimerDuration"
    
    init() {
        loadSettings()
        resetTimer()
        updateDisplayTimeString()
    }
    
    deinit {
        timer?.invalidate()
        autoSendTimer?.invalidate()
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        // 타이머 모드 로드
        if let savedMode = UserDefaults.standard.string(forKey: timerModeKey),
           let mode = TimerMode(rawValue: savedMode) {
            timerMode = mode
        }
        
        // 타이머 지속시간 로드
        let savedDuration = UserDefaults.standard.integer(forKey: timerDurationKey)
        if savedDuration > 0 {
            timerDurationMinutes = savedDuration
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(timerMode.rawValue, forKey: timerModeKey)
        UserDefaults.standard.set(timerDurationMinutes, forKey: timerDurationKey)
    }
    
    // MARK: - Timer Control
    
    func start() {
        DispatchQueue.main.async {
            guard !self.isRunning else { return }
            
            self.isRunning = true
            self.isPaused = false
            
            // 로그 기록 시작
            self.activityLogger.startLogging()
            print("🟢 Independent timer started - Activity logging started")
            
            // 자동 로그 전송 타이머 시작 (1분마다)
            self.autoSendTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
                Task {
                    await self?.sendLogs()
                }
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tick()
                }
            }
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
            self.autoSendTimer?.invalidate()
            self.autoSendTimer = nil
            self.isRunning = false
            self.isPaused = false
            
            // 로그 기록 중지 및 최종 전송
            self.activityLogger.stopLogging()
            print("🔴 Independent timer stopped - Activity logging stopped")
            
            Task {
                await self.sendLogs()
            }
            
            self.resetTimer()
        }
    }
    
    func pause() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
            self.autoSendTimer?.invalidate()
            self.autoSendTimer = nil
            self.isRunning = false
            self.isPaused = true
            
            // 일시정지 시에도 로그 기록 중지
            self.activityLogger.stopLogging()
            print("⏸️ Independent timer paused - Activity logging paused")
            
            Task {
                await self.sendLogs()
            }
        }
    }
    
    func resetTimer() {
        currentSeconds = timerMode == .timer ? (timerDurationMinutes * 60) : 0
        updateDisplayTimeString()
    }
    
    private func updateDisplayTimeString() {
        let hours = currentSeconds / 3600
        let minutes = (currentSeconds % 3600) / 60
        let seconds = currentSeconds % 60
        
        if hours > 0 {
            displayTimeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            displayTimeString = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func tick() {
        switch timerMode {
        case .stopwatch:
            currentSeconds += 1
        case .timer:
            currentSeconds -= 1
            
            // 타이머가 0에 도달하면 완료
            if currentSeconds <= 0 {
                currentSeconds = 0
                timer?.invalidate()
                timer = nil
                isRunning = false
                // 여기서 알림이나 완료 처리 가능
                timerCompleted()
            }
        }
        
        // 표시 시간 업데이트
        updateDisplayTimeString()
    }
    
    private func timerCompleted() {
        // 타이머 완료시 처리 (알림, 사운드 등)
        print("🔔 Timer completed!")
        
        // 로그 기록 중지 및 최종 전송
        activityLogger.stopLogging()
        Task {
            await sendLogs()
        }
        
        // 시스템 알림 보내기
        sendNotification()
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Completed"
        content.body = "Your \(timerDurationMinutes) minute timer has finished!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "timer_completed", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    // MARK: - Log Management
    
    private func sendLogs() async {
        do {
            try await uploadUseCase.syncLogs()
            print("📤 Independent timer logs synced successfully")
        } catch {
            print("❌ Failed to sync independent timer logs:", error)
        }
    }
    
    // MARK: - Settings Update
    
    func updateTimerMode(_ mode: TimerMode) {
        DispatchQueue.main.async {
            self.timerMode = mode
            self.saveSettings()
            self.resetTimer()
            self.updateDisplayTimeString()
        }
    }
    
    func updateTimerDuration(_ minutes: Int) {
        DispatchQueue.main.async {
            self.timerDurationMinutes = max(1, min(120, minutes)) // 1-120분 제한
            self.saveSettings()
            if self.timerMode == .timer {
                self.resetTimer()
            }
            self.updateDisplayTimeString()
        }
    }
    
    // MARK: - Computed Properties
    
    var displayTime: String {
        let hours = currentSeconds / 3600
        let minutes = (currentSeconds % 3600) / 60
        let seconds = currentSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var progressPercentage: Double {
        guard timerMode == .timer, timerDurationMinutes > 0 else { return 0 }
        let totalSeconds = timerDurationMinutes * 60
        return max(0, min(1, Double(currentSeconds) / Double(totalSeconds)))
    }
    
    var isTimerMode: Bool {
        return timerMode == .timer
    }
    
    var isStopwatchMode: Bool {
        return timerMode == .stopwatch
    }
}