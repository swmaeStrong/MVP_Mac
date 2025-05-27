//
//  AppCategory.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

struct AppCategory: Identifiable, Codable, Equatable {
    var id: String { category }
    let category: String
    let color: String
    let patterns: [String]?
}
