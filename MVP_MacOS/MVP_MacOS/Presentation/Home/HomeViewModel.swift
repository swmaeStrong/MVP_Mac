//
//  HomeViewModel.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import Combine
import Factory
import SwiftData

final class HomeViewModel: ObservableObject {
    @Published var isRunning = false

    private var timer: AnyCancellable?
    private var autoSendCancellable: AnyCancellable?
    
    var formattedTime: String {
        timeManager.getTodaySeconds().formattedHMSFromSeconds
    }
    
    @Injected(\.appUsageLogger) private var appUsageLogger
    @Injected(\.dailyWorkTimeManager) private var timeManager
    @Injected(\.uploadUsageUseCase) private var uploadUseCase
    @Injected(\.swiftDataManager) private var dataManager

    var context: ModelContext?
    
    func onTick() {
        timeManager.increment()
    }
    
    func toggleTimer() {
        timeManager.refreshIfNewDay()
        isRunning.toggle()
        if isRunning {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.timeManager.increment()
                    self?.objectWillChange.send()
                }

            autoSendCancellable = Timer.publish(every: 300, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.sendLogs()
                }

            if let context = context {
                appUsageLogger.configure(context: context)
            }
        } else {
            timer?.cancel()
            timer = nil

            autoSendCancellable?.cancel()
            autoSendCancellable = nil

            appUsageLogger.stopLogging()
            sendLogs()
        }
    }
    
    func sendLogs() {
        guard let context = context else { return }
        Task {
            let logs = dataManager.fetchAllAppLogs(context: context)
                .map { $0.toDomain()}
            do {
                try await uploadUseCase.execute(logs: logs)
                print("✅ Logs uploaded successfully")
                deleteAllData()
            } catch {
                print("❌ Failed to upload logs:", error)
            }
        }
    }
    func dataCount() {
        if let context = context {
            print("SwiftDataCount : \(dataManager.fetchAllAppLogs(context: context).count)")
        }
    }
    func deleteAllData() {
        if let context = context {
            do {
                try dataManager.deleteAllLogs(context: context)
                print("Successfully deleted all data")
            } catch {
                print("Faild to delete all data")
            }
        }
    }
}
