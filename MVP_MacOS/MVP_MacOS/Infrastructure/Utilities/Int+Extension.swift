//
//  Int+Extension.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation

extension Int {
    var formattedDuration: String {
        if self == 0 {
            return "< 1 min"
        }
        let hours = self / 60
        let mins = self % 60
        if hours > 0 && mins > 0 {
            return "\(hours) hr \(mins) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else {
            return "\(mins) min"
        }
    }
}
