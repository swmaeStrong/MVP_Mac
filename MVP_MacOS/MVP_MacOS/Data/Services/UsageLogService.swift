//
//  UsageLogService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/26/25.
//

import Foundation

final class UsageLogService {
    private let baseURL = URL(string: "http://3.39.105.127")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func upload(logs: [UsageLogDTO]) async throws {
        let url = baseURL.appendingPathComponent("/usage-log")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = try JSONEncoder().encode(logs)
        request.httpBody = body

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
