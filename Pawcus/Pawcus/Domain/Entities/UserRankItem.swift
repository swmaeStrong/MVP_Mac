//
//  File.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

struct UserRankItem: Codable {
//    var id = UUID()
    var userId: String = ""
    var nickname: String
    var score: Double
    var rank: Int
}
