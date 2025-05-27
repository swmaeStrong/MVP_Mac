//
//  FetchLeaderBoardUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

final class FetchLeaderBoardUseCase {
    private let repository: AnalysisRepository

    init(repository: AnalysisRepository) {
        self.repository = repository
    }

    func fetchLeaderBoardCategories() async throws -> [AppCategory] {
        return try await repository.getCategories()
    }
}
