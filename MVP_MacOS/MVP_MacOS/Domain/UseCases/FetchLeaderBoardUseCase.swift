//
//  FetchLeaderBoardUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

final class FetchLeaderBoardUseCase {
    private let analysisRepository: AnalysisRepository
    private let leaderBoardRepository: LeaderBoardRepository
    
    init(analysisRepository: AnalysisRepository, leaderBoardRepository: LeaderBoardRepository) {
        self.analysisRepository = analysisRepository
        self.leaderBoardRepository = leaderBoardRepository
    }

    func fetchLeaderBoardCategories() async throws -> [AppCategory] {
        return try await analysisRepository.getCategories()
    }
    
    func fetchLeaderBoard(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await leaderBoardRepository.getLeaderBoard(category: category, page: page, size: size, date: date)
    }
}
