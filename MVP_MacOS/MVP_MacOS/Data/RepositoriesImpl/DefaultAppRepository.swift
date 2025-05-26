//
//  DefaultAppRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation
import SwiftData

final class DefaultAppRepository: AppLogRepository {
    private let service: UsageLogService
    private let swiftDataManager: SwiftDataManager
    
    init(service: UsageLogService, swiftDataManager: SwiftDataManager) {
        self.service = service
        self.swiftDataManager = swiftDataManager
    }
    
    @MainActor
    func execute(context: ModelContext) async throws {
        Task {
            let logs = swiftDataManager.fetchAllAppLogs(context: context)
                .map { $0.toDomain().toDTO()}
            if !logs.isEmpty {
                do {
                    try await service.upload(logs: logs)
                    print("✅ Logs uploaded successfully")
                    try await deleteLog(context: context)
                } catch {
                    print("❌ Failed to upload logs:", error)
                }
            }
        }
    }
    
    @MainActor
    func deleteLog(context: ModelContext) async throws {
        do {
            try swiftDataManager.deleteAllLogs(context: context)
            print("Deleate All Log")
        } catch {
            print("Faild to delete all data")
        }
    }
    
}
