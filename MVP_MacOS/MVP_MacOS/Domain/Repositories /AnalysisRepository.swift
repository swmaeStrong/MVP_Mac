//
//  AnalysicsRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

protocol AnalysisRepository {
    func getCategories() async throws -> [AppCategory]
    func getUsageCategoryStat(userId: String?, date: Date) async throws -> [UsageCategoryStat]
}
