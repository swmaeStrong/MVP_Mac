//
//  UploadUsageLogUseCase.swift
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
    
    @MainActor
    func syncLogs(context: ModelContext) async throws {
        try await repository.execute(context: context)
    }
    
    @MainActor
    func deleteLog(context: ModelContext) async throws {
        try await repository.deleteLog(context: context)
    }
}
