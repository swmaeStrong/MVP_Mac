//
//  UserRank.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/20/25.
//

import Foundation

struct UserRank2: Identifiable {
    let id = UUID()
    let category: String
    let username: String
    let min: Int
    
    enum Category: String, CaseIterable {
        case development = "develop"
        case browsing = "documentation"
        case document = "design"
        case sns = "sns"
        case uncategorized = "uncategorized"
    }
}

extension UserRank2 {
    static let sampleData: [UserRank2] = [
        UserRank2(category: Category.development.rawValue, username: "Alice", min: 643),
        UserRank2(category: Category.development.rawValue, username: "Bob", min: 123),
        UserRank2(category: Category.development.rawValue, username: "Ivan", min: 354),
        UserRank2(category: Category.development.rawValue, username: "Julia", min: 221),
        UserRank2(category: Category.browsing.rawValue, username: "Charlie", min: 54),
        UserRank2(category: Category.browsing.rawValue, username: "Diana", min: 123),
        UserRank2(category: Category.browsing.rawValue, username: "Kevin", min: 764),
        UserRank2(category: Category.browsing.rawValue, username: "Laura", min: 865),
        UserRank2(category: Category.document.rawValue, username: "Ethan", min: 96),
        UserRank2(category: Category.document.rawValue, username: "Fiona", min: 33),
        UserRank2(category: Category.document.rawValue, username: "Mike", min: 44),
        UserRank2(category: Category.document.rawValue, username: "Nina", min: 243),
        UserRank2(category: Category.sns.rawValue, username: "George", min: 436),
        UserRank2(category: Category.sns.rawValue, username: "Hannah", min: 776),
        UserRank2(category: Category.sns.rawValue, username: "Oscar", min: 321),
        UserRank2(category: Category.uncategorized.rawValue, username: "Paula", min: 11)
    ]
}
