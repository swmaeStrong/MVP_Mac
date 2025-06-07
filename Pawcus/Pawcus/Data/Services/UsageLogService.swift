//
//  UsageLogService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation

final class UsageLogService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func uploadLogs(logs: [UsageLogDTO]) async throws {
        let endpoint = APIEndpoint.uploadLog
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method
        request.addJSONHeader()
        request.addBearerTokenIfAvailable()
        request.httpBody = try JSONEncoder().encode(logs)

        let (_, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, (400...499).contains(http.statusCode) {
            // 🔄 토큰 재발급 시도
            try await TokenManager.shared.refreshAccessTokenForGuest()
            // 📦 재시도 (토큰 교체 후)
            return try await uploadLogs(logs: logs)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
