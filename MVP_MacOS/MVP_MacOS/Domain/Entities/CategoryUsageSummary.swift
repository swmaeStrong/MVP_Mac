//
//  CategoryUsageSummary.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI

struct CategoryUsageSummary: Identifiable {
    var id: String { category }
    let category: String
    let duration: Int
    let color: Color
    
    static let sampleData: [CategoryUsageSummary] = [
        CategoryUsageSummary(category: "개발", duration: 270, color: .blue),
        CategoryUsageSummary(category: "브라우징", duration: 690, color: .green),
        CategoryUsageSummary(category: "문서작업", duration: 160, color: .orange),
        CategoryUsageSummary(category: "SNS", duration: 110, color: .purple),
        CategoryUsageSummary(category: "기타", duration: 40, color: .gray)
    ]
}
