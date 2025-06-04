//
//  File.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

struct UserRankItem: Codable {
    let userId: String
    let nickname: String
    let score: Double
    let rank: Int
}
