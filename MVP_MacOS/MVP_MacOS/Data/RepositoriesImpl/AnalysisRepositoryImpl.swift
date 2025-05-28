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
    
    func getUsageCategoryStat(userId: String? = nil , date: Date) async throws -> [UsageCategoryStat] {
        let userId = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        return try await service.fetchUsageCategoryStat(userId: userId, date: date.formattedDateString).map{$0.toDomain()}
    }
}
