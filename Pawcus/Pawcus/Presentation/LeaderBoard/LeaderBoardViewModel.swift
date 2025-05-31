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
    @Published var selectedCategory: String = "Development"
    @Published var top3Ranks: [String: [UserRankItem]] = [:]
    @Published var otherRanks: [String: [UserRankItem]] = [:]
    @Published var selectedDate: Date = Date()
    private var categories: [AppCategory] = []
    
    init() {
        Task {
            await loadCategories()
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
    
    @MainActor
    func loadUserTop10RanksByCategory(page: Int? = nil, size: Int? = nil) async {
        do {
            let userRanks = try await fetchLeaderBoardUseCase.fetchLeaderBoard(category: selectedCategory, page: page, size: size, date: selectedDate.formattedDateString)
            userRankItems[selectedCategory] = userRanks
        } catch {
            print("Error fetching leaderboard: \(error)")
        }
    }
    
}
