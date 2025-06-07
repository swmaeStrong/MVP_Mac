//
//  AppLogRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation
import SwiftData

protocol AppLogRepository {
    func uploadLogsToServer(context: ModelContext) async throws
    func clearLocalLogs(context: ModelContext) async throws
}
