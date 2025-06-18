//
//  AppCategoryDTO.swift
//  Pawcus
//
//  Created by 김정원 on 6/18/25.
//

import Foundation

struct AppCategoryDTO: Codable  {
    let category: String
    let appPatterns: [String]?
    
    func toDomain() -> AppCategory {
        .init(category: category, color: AppCategoryType(from: category).colorHex, patterns: appPatterns ?? [])
    }
}
