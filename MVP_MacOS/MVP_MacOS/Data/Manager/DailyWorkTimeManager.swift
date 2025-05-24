//
//  DailyWorkTimeManager.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI

final class DailyWorkTimeManager {
    @AppStorage("dailyWorkSeconds") private var seconds: Int = 0
    @AppStorage("lastRecordedDate") private var lastDate: String = ""

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    func refreshIfNewDay() {
        let today = dateFormatter.string(from: Date())
        if lastDate != today {
            seconds = 0
            lastDate = today
        }
    }

    func increment() {
        seconds += 1
    }

    func getTodaySeconds() -> Int {
        return seconds
    }

    func reset() {
        seconds = 0
        lastDate = dateFormatter.string(from: Date())
    }
}
