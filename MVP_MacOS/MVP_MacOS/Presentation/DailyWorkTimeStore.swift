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
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @AppStorage("lastRecordedDate") private var storedDate: String = ""

    @Published private(set) var seconds: Int = 0
    @Injected(\.syncUsageLogsUseCase) private var uploadUseCase
    @Injected(\.appUsageLogger) private var appUsageLogger
    private var timer: AnyCancellable?
    private var autoSendCancellable: AnyCancellable?

    @Published var isRunning = false
    var context: ModelContext?

    // MARK: - Initialization
    init() {
        refreshIfNewDay()
        seconds = storedSeconds
    }

    // MARK: - 상태 갱신 메서드

    /// 날짜를 갱신하여 누적 시간을 초기화 시키는 메서드
    func refreshIfNewDay() {
        let today = dateFormatter.string(from: Date())
        if storedDate != today {
            storedSeconds = 0
            storedDate = today
        }
        seconds = storedSeconds
    }

    func increment() {
        seconds += 1
        storedSeconds = seconds
    }
    
    func reset() {
        seconds = 0
        storedSeconds = 0
        storedDate = dateFormatter.string(from: Date())
    }

    // MARK: - 타이머 시작/중지

    /// 5분에 한번씩 보내는 로직
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
            try await uploadUseCase.execute(context: context)
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

    // MARK: - 유틸리티

    var formattedTime: String {
        seconds.formattedHMSFromSeconds
    }

    /// Date formatter for "yyyy-MM-dd" format.
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
