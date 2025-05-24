//
//  AppLog.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation

struct AppLog {
    var id: String {
        UserDefaults.standard.string(forKey: "username") ?? UUID().uuidString
    }
    var timestamp: Date
    var duration: TimeInterval
    var title: String
    var app: String
}
