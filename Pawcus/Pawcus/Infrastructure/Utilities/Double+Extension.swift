//
//  Double+Extension.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

extension Double {
    /// min를 기반으로 1hr 30min 형식으로 바꿔줌
    var formattedDurationFromMinutes: String {
        return Int(self).formattedDurationFromMinutes
    }
    
    /// sec를 기반으로 1hr 30min 형식으로 바꿔줌
    var formattedDurationFromSeconds: String {
        return Int(self).formattedDurationFromSeconds
    }
    
    /// sec를 기반으로 1hr 30min 형식으로 바꿔줌 BarChart 버전
    var formattedDurationFromSecondsForBarChart: String {
        return Int(self).formattedDurationFromSecondsForBarChart
    }
    
    /// sec 를 기반으로 "hh:mm:ss" 형태로 변경
    var formattedHMSFromSeconds: String {
        return Int(self).formattedHMSFromSeconds
    }
}
