//
//  UserRank.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/20/25.
//

import Foundation

struct UserRank: Identifiable {
    let id = UUID()
    let category: Category
    let username: String
    let min: Int
    
    enum Category: String, CaseIterable {
        case development = "Development"
        case browsing = "Browsing"
        case document = "Document"
        case sns = "SNS"
    }
}

extension UserRank {
    static let sampleData: [UserRank] = [
        UserRank(category: .development, username: "Alice", min: 643),
        UserRank(category: .development, username: "Bob", min: 123),
        UserRank(category: .development, username: "Ivan", min: 354),
        UserRank(category: .development, username: "Julia", min: 221),
        UserRank(category: .browsing, username: "Charlie", min: 54),
        UserRank(category: .browsing, username: "Diana", min: 123),
        UserRank(category: .browsing, username: "Kevin", min: 764),
        UserRank(category: .browsing, username: "Laura", min: 865),
        UserRank(category: .document, username: "Ethan", min: 96),
        UserRank(category: .document, username: "Fiona", min: 33),
        UserRank(category: .document, username: "Mike", min: 44),
        UserRank(category: .document, username: "Nina", min: 243),
        UserRank(category: .sns, username: "George", min: 436),
        UserRank(category: .sns, username: "Hannah", min: 776),
        UserRank(category: .sns, username: "Oscar", min: 321),
        UserRank(category: .sns, username: "Paula", min: 11)
    ]
}
