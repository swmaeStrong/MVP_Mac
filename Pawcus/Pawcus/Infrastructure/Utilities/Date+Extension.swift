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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.current // 로컬 시간 사용
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
}
