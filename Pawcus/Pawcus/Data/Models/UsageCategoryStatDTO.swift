//
//  UsageCategoryStatDTO.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

struct UsageCategoryStatDTO: Codable {
    var category: String
    var duration: Double
    var color: String
}

extension UsageCategoryStatDTO {
    func toDomain() -> UsageCategoryStat {
        UsageCategoryStat(
            category: category,
            duration: duration,
            color: color
        )
    }
}
