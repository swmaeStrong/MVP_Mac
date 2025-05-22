//
//  DeviceID.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/20/25.
//

import Foundation

struct DeviceID {
    private static let key = "com.myapp.deviceID"

    static var current: String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: key)
            return newID
        }
    }
}
