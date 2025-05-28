//
//  LeaderBoardRepositoryImpl.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

final class LeaderBoardRepositoryImpl: LeaderBoardRepository {
    
    private let service: UserRankService

    init(service: UserRankService) {
        self.service = service
    }
    
    func getLeaderBoardByCategory(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await service.fetchUserRanksByCategory(category: category, page: page, size: size, date: date)
    }
    
    func getTop10UserRanksLeaderBoard() async throws -> [String: [UserRankItem]] {
        return try await service.fetchUserTop10Ranks()
    }
    
}
