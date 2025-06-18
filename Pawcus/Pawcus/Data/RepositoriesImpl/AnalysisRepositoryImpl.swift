//
//  AnalysicsRepositoryImpl.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

final class AnalysisRepositoryImpl: AnalysisRepository {
    private let service: UsageAnalysisService

    init(service: UsageAnalysisService) {
        self.service = service
    }

    func getCategories() async throws -> [AppCategory] {
        return try await service.fetchAppCategories().map{$0.toDomain()}
    }
    
    func getUsageCategoryStat(userId: String? = nil , date: Date) async throws -> [UsageCategoryStat] {
        let userId = UserDefaults.standard.string(forKey: .userId) ?? UUID().uuidString
        return try await service.fetchUsageCategoryStat(userId: userId, date: date.formattedDateString).map{$0.toDomain()}
    }
}
