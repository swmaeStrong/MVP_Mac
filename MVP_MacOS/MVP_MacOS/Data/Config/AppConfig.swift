//
//  AppConfig.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

enum AppConfig {
    static var baseURL: String {
        let domain = Bundle.main.infoDictionary?["BASE_DOMAIN"] as? String ?? ""
        return "http://\(domain)"
    }
}
