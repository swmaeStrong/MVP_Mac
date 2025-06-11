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
    
    func uploadLogsToServer() async throws {
        Task {
            let logs = appLogLocalDataSource.fetchAllAppLogs()
                .map { $0.toDTO()}
            if !logs.isEmpty {
                do {
                    try await service.uploadLogs(logs: logs)
                    print("✅ Logs uploaded successfully")
                    try await clearLocalLogs()
                } catch {
                    print("❌ Failed to upload logs:", error)
                }
            }
        }
    }
    
    func clearLocalLogs() async throws {
        do {
            try appLogLocalDataSource.removeAllAppLogs()
            print("Deleate All Log")
        } catch {
            print("Faild to delete all data")
        }
    }
    
}
