//
//  WorkTimeManager.swift
//  Pawcus
//
//  Created by 김정원 on 6/20/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import Factory

enum WorkTimeMode: String, CaseIterable {
    case stopwatch = "stopwatch"       // 스톱워치 모드
    case timer = "timer"               // 카운트다운 타이머 모드
    
    var displayName: String {
        switch self {
        case .stopwatch:
            return "Stopwatch"
        case .timer:
            return "Timer"
        }
    }

    var color: Color {
        switch self {
        case .stopwatch:
            return .red
        case .timer:
            return .accent
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

@MainActor
final class WorkTimeManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var mode: WorkTimeMode = .stopwatch
    @Published var timerDurationMinutes: Int = 25 // 타이머 모드용 기본 25분
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    
    // 현재 시간 (초 단위)
    @Published private(set) var currentSeconds: Int = 0
    @Published private(set) var displayTimeString: String = "00:00"
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var autoSendCancellable: AnyCancellable?
    
    // 로그 기록을 위한 의존성
    @Injected(\.activityLogger) private var activityLogger
    @Injected(\.transferUsageLogsUseCase) private var uploadUseCase
    
    // MARK: - Initialization
    init() {
        loadSettings()
        resetTimer()
        updateDisplayTimeString()
    }
    
    deinit {
        timer?.cancel()
        autoSendCancellable?.cancel()
        // Note: activityLogger cleanup handled by the logger itself
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        // 작업 모드 로드
        if let savedMode = UserDefaults.standard.string(forKey: .timerMode),
           let workMode = WorkTimeMode(rawValue: savedMode) {
            mode = workMode
        }
        
        // 타이머 지속시간 로드
        let savedDuration = UserDefaults.standard.integer(forKey: .timerDuration)
        if savedDuration > 0 {
            timerDurationMinutes = savedDuration
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(mode.rawValue, forKey: .timerMode)
        UserDefaults.standard.set(timerDurationMinutes, forKey: .timerDuration)
    }
    
    // MARK: - Timer Control
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        isPaused = false
        
        // 로그 기록 시작
        activityLogger.startLogging()
        print("🟢 WorkTimeManager started (\(mode.displayName)) - Activity logging started")
        
        // 자동 로그 전송 타이머 시작 (1분마다)
        autoSendCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.sendLogs()
                }
            }
        
        // 타이머 시작
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        autoSendCancellable?.cancel()
        autoSendCancellable = nil
        
        isRunning = false
        isPaused = false
        
        // 로그 기록 중지 및 최종 전송
        activityLogger.stopLogging()
        print("🔴 WorkTimeManager stopped (\(mode.displayName)) - Activity logging stopped")
        
        Task {
            await sendLogs()
        }
        
        resetTimer()
    }
    
    func pause() {
        timer?.cancel()
        timer = nil
        autoSendCancellable?.cancel()
        autoSendCancellable = nil
        
        isRunning = false
        isPaused = true
        
        // 일시정지 시에도 로그 기록 중지
        activityLogger.stopLogging()
        print("⏸️ WorkTimeManager paused (\(mode.displayName)) - Activity logging paused")
        
        Task {
            await sendLogs()
        }
    }
    
    func resume() {
        guard isPaused else { return }
        start()
    }
    
    func resetTimer() {
        switch mode {
        case .stopwatch:
            currentSeconds = 0
        case .timer:
            currentSeconds = timerDurationMinutes * 60
        }
        updateDisplayTimeString()
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        switch mode {
        case .stopwatch:
            currentSeconds += 1
        case .timer:
            currentSeconds -= 1
            
            // 타이머가 0에 도달하면 완료
            if currentSeconds <= 0 {
                currentSeconds = 0
                timerCompleted()
            }
        }
        
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
    
    private func timerCompleted() {
        print("🔔 Timer completed!")
        
        // 타이머 완료 시 정지 (로그 기록도 함께 중지됨)
        stop()
        
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
                print("❌ Failed to send notification: \(error)")
            }
        }
    }
    
    // MARK: - Log Management
    
    private func sendLogs() async {
        do {
            try await uploadUseCase.syncLogs()
            print("📤 WorkTimeManager logs synced successfully")
        } catch {
            print("❌ Failed to sync WorkTimeManager logs:", error)
        }
    }
    
    // MARK: - Settings Update
    
    func updateMode(_ newMode: WorkTimeMode) {
        guard !isRunning else { return } // 실행 중일 때는 모드 변경 불가
        
        mode = newMode
        saveSettings()
        resetTimer()
    }
    
    func updateTimerDuration(_ minutes: Int) {
        timerDurationMinutes = max(1, min(120, minutes)) // 1-120분 제한
        saveSettings()
        
        if mode == .timer && !isRunning {
            resetTimer()
        }
    }
    
    func increaseTimerDuration(step: Int = 5) {
        let newValue = timerDurationMinutes + step
        if newValue > 120 {
            updateTimerDuration(5) // 롤오버
        } else {
            updateTimerDuration(newValue)
        }
    }

    func decreaseTimerDuration(step: Int = 5) {
        let newValue = timerDurationMinutes - step
        updateTimerDuration(max(5, newValue)) // 최소 5 유지
    }
    
    // MARK: - Computed Properties
    
    var progressPercentage: Double {
        guard mode == .timer, timerDurationMinutes > 0 else { return 0 }
        let totalSeconds = timerDurationMinutes * 60
        return max(0, min(1, Double(currentSeconds) / Double(totalSeconds)))
    }
    
    var isTimerMode: Bool {
        return mode == .timer
    }
    
    var isStopwatchMode: Bool {
        return mode == .stopwatch
    }
    
    var canPause: Bool {
        return isRunning
    }
    
    var formattedTime: String {
        return displayTimeString
    }
}
