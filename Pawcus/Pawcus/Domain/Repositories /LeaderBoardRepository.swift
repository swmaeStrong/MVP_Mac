//
//  LeaderBoardRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

protocol LeaderBoardRepository {
    func getLeaderBoardByCategoryOnDate(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem]
    func getLeaderBoardByCategoryOnWeekly(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem]
    func getLeaderBoardByCategoryOnMonthly(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem]
    func getTop10UserRanksLeaderBoard() async throws -> [String: [UserRankItem]]
}
