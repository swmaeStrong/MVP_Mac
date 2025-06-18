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
        
    @Published private(set) var seconds: Int = 0
    @Published var isRunning = false
    @Published var isAppDisabled = false
    
    private var timer: AnyCancellable?
    private var autoSendCancellable: AnyCancellable?

    // MARK: - 타이머 시작/중지
    
    func start() {
        seconds = 0
        appUsageLogger.startLogging()
        isRunning = true
        isAppDisabled = true
        if isRunning {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.seconds += 1
                }
            autoSendCancellable = Timer.publish(every: 60, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task {
                        await self?.sendLogs()
                    }
                }
        }
    }

    func stop() {
        appUsageLogger.stopLogging()
        isRunning = false
        isAppDisabled = false
        timer?.cancel()
        timer = nil
        Task {
            await sendLogs()
        }
    }

    // MARK: - 로그 전송/삭제
    func sendLogs() async {
        do {
            try await uploadUseCase.syncLogs()
        } catch {
            print("❌ Failed to upload logs:", error)
        }
    }

    func deleteLogs() async {
        do {
            try await uploadUseCase.deleteLog()
            print("Successfully deleted logs.")
        } catch {
            print("❌ Failed to delete logs:", error)
        }
    }
}
