//
//  AnalysicsRepositoryImpl.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

final class AnalysisRepositoryImpl: AnalysisRepository {
    private let service: AnalysisService

    init(service: AnalysisService) {
        self.service = service
    }

    func getCategories() async throws -> [AppCategory] {
        return try await service.fetchAppCategories()
    }
}
