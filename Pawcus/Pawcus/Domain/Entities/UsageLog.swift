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
    var url: String
}
