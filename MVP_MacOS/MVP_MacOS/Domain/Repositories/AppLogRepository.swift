//
//  AppLogRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation
import SwiftData

protocol AppLogRepository {
    @MainActor func uploadLogsToServer(context: ModelContext) async throws
    @MainActor func clearLocalLogs(context: ModelContext) async throws
}
