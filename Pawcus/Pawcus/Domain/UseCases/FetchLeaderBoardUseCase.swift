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
    
    func fetchLeaderBoardOnDate(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await leaderBoardRepository.getLeaderBoardByCategoryOnDate(category: category, page: page, size: size, date: date)
    }
    
    func fetchLeaderBoardOnWeekly(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await leaderBoardRepository.getLeaderBoardByCategoryOnWeekly(category: category, page: page, size: size, date: date)
    }
    
    func fetchLeaderBoardOnMonthly(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await leaderBoardRepository.getLeaderBoardByCategoryOnMonthly(category: category, page: page, size: size, date: date)
    }
    
    func fetchGlobalTop10UserRanks() async throws -> [String: [UserRankItem]] {
        return try await leaderBoardRepository.getTop10UserRanksLeaderBoard()
    }
}
