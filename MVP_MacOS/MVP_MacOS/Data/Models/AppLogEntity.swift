//
//  AppLogEntity.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/20/25.
//

import Foundation
import SwiftData

@Model
final class AppLogEntity {
    @Attribute(.unique)
    var timestamp: Date
    var duration: TimeInterval
    var title: String
    var app: String

    init(
        timestamp: Date,
        duration: TimeInterval,
        title: String,
        app: String
    ) {
        self.timestamp = timestamp
        self.duration = duration
        self.title = title
        self.app = app
    }
}

extension AppLogEntity {
    /// Domain 모델인 AppLog로 변환
    func toDomain() -> UsageLog {
        UsageLog(
            timestamp: timestamp,
            duration: duration,
            title: title,
            app: app
        )
    }
    
    func toDTO() -> UsageLogDTO {
        let formatter = ISO8601DateFormatter()
        let userId = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        return UsageLogDTO(
            userId: userId,
            title: title,
            app: app,
            duration: duration,
            timestamp: formatter.string(from: timestamp)
        )
    }

    /// Domain 모델을 받아 SwiftData 엔티티 생성
    convenience init(from domain: UsageLog) {
        self.init(
            timestamp: domain.timestamp,
            duration: domain.duration,
            title: domain.title,
            app: domain.app
        )
    }
}
