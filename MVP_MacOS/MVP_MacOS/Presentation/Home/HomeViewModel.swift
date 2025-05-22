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
    
    var formattedTime: String {
        timeManager.getTodaySeconds().formattedHMSFromSeconds
    }
    
    @Injected(\.appUsageLogger) private var appUsageLogger
    @Injected(\.dailyWorkTimeManager) private var timeManager

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
            if let context = context {
                appUsageLogger.configure(context: context)
            }
        } else {
            timer?.cancel()
            timer = nil
            appUsageLogger.stopLogging()
        }
    }
}
