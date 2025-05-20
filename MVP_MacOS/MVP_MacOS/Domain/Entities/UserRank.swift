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
    let hours: Double
    
    enum Category: String, CaseIterable {
        case development = "개발"
        case browsing = "브라우징"
        case document = "문서작업"
        case sns = "SNS"
    }
}

extension UserRank {
    static let sampleData: [UserRank] = [
        UserRank(category: .development, username: "Alice", hours: 12.5),
        UserRank(category: .development, username: "Bob", hours: 10.0),
        UserRank(category: .development, username: "Ivan", hours: 8.3),
        UserRank(category: .development, username: "Julia", hours: 7.0),
        UserRank(category: .browsing, username: "Charlie", hours: 8.0),
        UserRank(category: .browsing, username: "Diana", hours: 7.5),
        UserRank(category: .browsing, username: "Kevin", hours: 6.8),
        UserRank(category: .browsing, username: "Laura", hours: 5.9),
        UserRank(category: .document, username: "Ethan", hours: 9.0),
        UserRank(category: .document, username: "Fiona", hours: 6.5),
        UserRank(category: .document, username: "Mike", hours: 7.4),
        UserRank(category: .document, username: "Nina", hours: 6.2),
        UserRank(category: .sns, username: "George", hours: 5.0),
        UserRank(category: .sns, username: "Hannah", hours: 4.2),
        UserRank(category: .sns, username: "Oscar", hours: 4.5),
        UserRank(category: .sns, username: "Paula", hours: 3.8)
    ]
}
