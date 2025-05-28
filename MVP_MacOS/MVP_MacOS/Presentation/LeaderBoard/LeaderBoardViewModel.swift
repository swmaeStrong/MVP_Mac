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
    @Published var userRankItems: [UserRankItem] = []

    private var categories: [AppCategory] = []
    
    init() {
        Task {
            await loadCategories()
//            await loadUserRanks(date: Date())
            
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
    
    @MainActor
    func loadUserRanks(page: Int? = nil, size: Int? = nil, date: Date) async {
        do {
            for category in categories {
                let userRank = try await fetchLeaderBoardUseCase.fetchLeaderBoard(category: category.category, page: page, size: size, date: date.formattedDateString)
                print(userRank)
                userRankItems.append(contentsOf: userRank)
            }
        } catch {
            print("Error fetching leaderboard: \(error)")
        }
    }
}
