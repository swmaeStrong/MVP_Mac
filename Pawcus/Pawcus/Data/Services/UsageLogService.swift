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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(logs)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
