//
//  LeaderBoardRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

protocol LeaderBoardRepository {
    func getLeaderBoard(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem]
}
