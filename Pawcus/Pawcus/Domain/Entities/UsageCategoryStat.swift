//
//  UsageCategoryStat.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

struct UsageCategoryStat: Identifiable {
    var id = UUID()
    var category: String
    var duration: Double
    var color: String
}
