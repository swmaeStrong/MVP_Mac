//
//  AppLog.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation

struct UsageLog: Codable {
    var id: String = ""
    var timestamp: Date
    var duration: TimeInterval
    var title: String
    var app: String
}

extension UsageLog {
    func toDTO() -> UsageLogDTO {
        let formatter = ISO8601DateFormatter()
        let userId = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        print(userId)
        return UsageLogDTO(
            userId: userId,
            title: title,
            app: app,
            duration: duration,
            timestamp: formatter.string(from: timestamp)
        )
    }
}
