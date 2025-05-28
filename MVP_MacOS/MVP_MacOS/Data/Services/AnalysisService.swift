//
//  AnalysicsService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

final class AnalysisService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAppCategories() async throws -> [AppCategory] {
        let endpoint = APIEndpoint.getCategories
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let categories = try JSONDecoder().decode([AppCategory].self, from: data)
        return categories
    }
    
    
}
