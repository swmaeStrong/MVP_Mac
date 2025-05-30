//
//  DailyWorkTimeManager.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI
import Combine
import Factory
import SwiftData

final class DailyWorkTimeStore: ObservableObject {
    
    @Injected(\.transferUsageLogsUseCase) private var uploadUseCase
    @Injected(\.activityLogger) private var appUsageLogger
    
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @AppStorage("lastRecordedDate") private var storedDate: String = ""
    
    @Published private(set) var seconds: Int = 0
    @Published var isRunning = false
    @Published var hours: Int = 0
    @Published var min: Int = 0
    @Published var sec: Int = 0

    
    private var timer: AnyCancellable?
    private var autoSendCancellable: AnyCancellable?
   
    var context: ModelContext?

    // MARK: - Initialization
    init() {
        refreshIfNewDay()
        seconds = storedSeconds
        setTime(storedSeconds)
    }

    // MARK: - 상태 갱신 메서드
    private func setTime(_ totalSeconds: Int) {
        hours = totalSeconds / 3600
        min = (totalSeconds % 3600) / 60
        sec = totalSeconds % 60
    }
    
    /// 날짜를 갱신하여 누적 시간을 초기화 시키는 메서드
    func refreshIfNewDay() {
        let today = Date().formattedDateString
        if storedDate != today {
            storedSeconds = 0
            storedDate = today
        }
        seconds = storedSeconds
    }

    func increment() {
        seconds += 1
        setTime(seconds)
        storedSeconds = seconds
    }
    
    func reset() {
        seconds = 0
        storedSeconds = 0
        storedDate = Date().formattedDateString
    }

    // MARK: - 타이머 시작/중지

    func start() {
        isRunning = true
        refreshIfNewDay()
        if isRunning {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.increment()
                }
            autoSendCancellable = Timer.publish(every: 300, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task {
                        await self?.sendLogs()
                    }
                }
        }
    }

    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
        Task {
            await sendLogs()
        }
    }

    // MARK: - 로그 전송/삭제
    @MainActor
    func sendLogs() async {
        guard let context = context else { return }
        do {
            try await uploadUseCase.syncLogs(context: context)
        } catch {
            print("❌ Failed to upload logs:", error)
        }
    }

    @MainActor
    func deleteLogs() async {
        guard let context = context else { return }
        do {
            try await uploadUseCase.deleteLog(context: context)
            print("Successfully deleted logs.")
        } catch {
            print("❌ Failed to delete logs:", error)
        }
    }
}
