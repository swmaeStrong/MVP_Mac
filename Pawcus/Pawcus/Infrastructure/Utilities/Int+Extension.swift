//
//  Int+Extension.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation

extension Int {
    /// min를 기반으로 1hr 30min 형식으로 바꿔줌
    var formattedDurationFromMinutes: String {
        if self < 1 {
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
    
    /// sec를 기반으로 1hr 30min 형식으로 바꿔줌
    var formattedDurationFromSeconds: String {
        if self < 60 {
            return "< 1 min"
        }
        let hours = self / 3600
        let mins = (self % 3600) / 60
        if hours > 0 && mins > 0 {
            return "\(hours) hr \(mins) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else {
            return "\(mins) min"
        }
    }
    
    var formattedDurationFromSecondsForBarChart: String {
        if self < 60 {
            return ""
        }
        let hours = self / 3600
        let mins = (self % 3600) / 60
        if hours > 0 && mins > 0 {
            return "\(hours) hr \(mins) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else {
            return "\(mins) min"
        }
    }
    
    /// sec 를 기반으로 "hh:mm:ss" 형태로 변경
    var formattedHMSFromSeconds: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
