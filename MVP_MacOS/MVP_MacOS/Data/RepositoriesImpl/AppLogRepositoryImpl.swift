//
//  DefaultAppRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation
import SwiftData

final class AppLogRepositoryImpl: AppLogRepository {
    private let service: UsageLogService
    private let appLogLocalDataSource: AppLogLocalDataSource
    
    init(service: UsageLogService, appLogLocalDataSource: AppLogLocalDataSource) {
        self.service = service
        self.appLogLocalDataSource = appLogLocalDataSource
    }
    
    @MainActor
    func execute(context: ModelContext) async throws {
        Task {
            let logs = appLogLocalDataSource.fetchAllAppLogs(context: context)
                .map { $0.toDTO()}
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
            try appLogLocalDataSource.deleteAllLogs(context: context)
            print("Deleate All Log")
        } catch {
            print("Faild to delete all data")
        }
    }
    
}
