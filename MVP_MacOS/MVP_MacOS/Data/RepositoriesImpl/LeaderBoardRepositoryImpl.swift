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
    
    func getLeaderBoard(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        return try await service.fetchUserRanks(category: category, page: page, size: size, date: date)
    }
    
}
