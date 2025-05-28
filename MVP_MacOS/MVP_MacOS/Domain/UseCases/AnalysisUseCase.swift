//
//  AnalysisUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

final class AnalysisUseCase {
    private let analysisRepository: AnalysisRepository
    
    init(analysisRepository: AnalysisRepository) {
        self.analysisRepository = analysisRepository
    }

    func fetchLeaderBoardCategories() async throws -> [AppCategory] {
        return try await analysisRepository.getCategories()
    }
    
    func fetchUsageCategoryStat(date: Date) async throws -> [UsageCategoryStat] {
        return try await analysisRepository.getUsageCategoryStat(userId: nil , date: date)
    }
}
