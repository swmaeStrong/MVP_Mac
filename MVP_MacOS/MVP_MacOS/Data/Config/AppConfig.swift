//
//  AppConfig.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

let baseDomain = Bundle.main.infoDictionary?["BASE_DOMAIN"] as? String
let baseURL = "http://\(baseDomain ?? "")"
