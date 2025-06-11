//
//  TransferUsageLogsUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation
import Factory
import SwiftData

final class TransferUsageLogsUseCase {
    private let repository: AppLogRepository
    
    init(repository: AppLogRepository) {
        self.repository = repository
    }
    
    func syncLogs() async throws {
        try await repository.uploadLogsToServer()
    }
    
    func deleteLog() async throws {
        try await repository.clearLocalLogs()
    }
}
