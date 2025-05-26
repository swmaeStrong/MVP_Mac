//
//  UploadUsageLogUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation

final class UploadUsageLogUseCase {
    private let service: UsageLogService

    init(service: UsageLogService) {
        self.service = service
    }

    func execute(logs: [UsageLog]) async throws {
        let logs = logs.map{$0.toDTO()}
        try await service.upload(logs: logs)
    }
}
