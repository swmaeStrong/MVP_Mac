//
//  UsageLogDTO.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation

struct UsageLogDTO: Codable {
    let title: String
    let app: String
    let duration: Double
    let timestamp: String
    let url: String
}


