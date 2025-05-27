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

    private var categories: [AppCategory] = []
    
    init() {
        Task { await load() }
    }
    
    @MainActor
    func load() async {
        do {
            let categories = try await fetchLeaderBoardUseCase.fetchLeaderBoardCategories()
            self.categories = categories
            self.categoryNames = categories.map { $0.category }
        } catch {
            print("❌ Error fetching leaderboard categories: \(error)")
        }
    }
}
