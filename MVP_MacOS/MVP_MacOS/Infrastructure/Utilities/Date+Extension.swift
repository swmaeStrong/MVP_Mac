//
//  Data+Extension.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
    
    var iso8601WithMillisecondsUTC: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds // 밀리초 포함
        ]
        return formatter.string(from: self)
    }
    
}
