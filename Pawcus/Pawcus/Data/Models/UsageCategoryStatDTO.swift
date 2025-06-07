//
//  UsageCategoryStatDTO.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

struct UsageCategoryStatDTO: Codable {
    let category: String
    let duration: Double
    let color: String
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
