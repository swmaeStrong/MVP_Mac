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

class HomeViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false

    private var timer: AnyCancellable?
    private let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.zeroFormattingBehavior = .pad
        return f
    }()

    @Injected(\.appUsageLogger) private var appUsageLogger
    var context: ModelContext?

    func toggleTimer() {
        isRunning.toggle()
        if isRunning {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.elapsedTime += 1
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

    var formattedTime: String {
        formatter.string(from: elapsedTime) ?? "00:00:00"
    }
}
