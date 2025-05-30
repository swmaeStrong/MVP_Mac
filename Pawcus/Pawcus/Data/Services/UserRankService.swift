//
//  UserRankService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/28/25.
//

import Foundation

final class UserRankService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUserRanksByCategory(category: String, page: Int?, size: Int?, date: String) async throws -> [UserRankItem] {
        let endpoint = APIEndpoint.getUserRanksByCategory(category: category, page: page, size: size, date: date)
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let ranks = try JSONDecoder().decode([UserRankItem].self, from: data)
        return ranks
    }
       
    func fetchUserTop10Ranks() async throws -> [String: [UserRankItem]] {
        let endpoint = APIEndpoint.getUserTop10Ranks
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let ranksByCategory = try JSONDecoder().decode([String: [UserRankItem]].self, from: data)
        return ranksByCategory
    }
}
