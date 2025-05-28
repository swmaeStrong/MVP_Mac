//
//  LeaderBoardViewModel.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI
import Factory

final class LeaderBoardViewModel: ObservableObject {
    @Injected(\.fetchLeaderBoardUseCase) private var fetchLeaderBoardUseCase
    
    @Published var categoryNames: [String] = []
    @Published var userRankItems: [String: [UserRankItem]] = [:]
    @Published var selectedCategory: String = "develop"
    @Published var top3Ranks: [String: [UserRankItem]] = [:]
    @Published var otherRanks: [String: [UserRankItem]] = [:]
    
    private var categories: [AppCategory] = []
    
    init() {
        Task {
            await loadCategories()
            await loadUserTop10Ranks()
        }
        
    }
    
    @MainActor
    func loadCategories() async {
        do {
            let categories = try await fetchLeaderBoardUseCase.fetchLeaderBoardCategories()
            print(categories)
            self.categories = categories
            self.categoryNames = categories.map { $0.category }
        } catch {
            print("❌ Error fetching leaderboard categories: \(error)")
        }
    }
    
    func top3RankUsers() -> [UserRankItem] {
        let ranks = userRankItems[selectedCategory]?.sorted(by: { $0.score > $1.score }) ?? []
        return Array(ranks.prefix(3))
    }
    
    func otherRankUsers() -> [UserRankItem] {
        let ranks = userRankItems[selectedCategory]?.sorted(by: { $0.score > $1.score }) ?? []
        return Array(ranks.dropFirst(3))
    }
    
//    @MainActor
//    func loadUserRanks(page: Int? = nil, size: Int? = nil, date: Date) async {
//        do {
//            for category in categories {
//                let userRank = try await fetchLeaderBoardUseCase.fetchLeaderBoard(category: category.category, page: page, size: size, date: date.formattedDateString)
//                print(userRank)
//                userRankItems.append(contentsOf: userRank)
//            }
//        } catch {
//            print("Error fetching leaderboard: \(error)")
//        }
//    }
    
    @MainActor
    func loadUserTop10Ranks() async {
        do {
            let userRanks = try await fetchLeaderBoardUseCase.fetchGlobalTop10UserRanks()
            userRankItems = userRanks
        } catch {
            print("Error fetching leaderboard: \(error)")
        }
    }
    
}
