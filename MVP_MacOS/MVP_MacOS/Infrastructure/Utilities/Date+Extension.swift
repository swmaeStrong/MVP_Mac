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
}
