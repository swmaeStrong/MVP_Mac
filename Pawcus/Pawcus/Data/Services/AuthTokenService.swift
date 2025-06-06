//
//  AuthTokenService.swift
//  Pawcus
//
//  Created by 김정원 on 6/5/25.
//

import Foundation

enum AuthError: Error {
    case tokenRefreshFailed
    case noUserData
}

final class TokenManager {
    static let shared = TokenManager()

    private init() {}

    func getAccessToken() async throws -> String {
        if let accessToken = KeychainHelper.standard.read(service: "accessToken", account: "pawcus"){
            return accessToken
        } else {
            return try await refreshAccessToken()
        }
    }

    private func refreshAccessToken() async throws -> String {
        if let refreshToken = KeychainHelper.standard.read(service: "refreshToken", account: "pawcus") {
            // 🔁 RTK로 토큰 재발급
            let url = APIEndpoint.tokenRefresh.url()
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["refreshToken": refreshToken])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw AuthError.tokenRefreshFailed
            }
            let newTokens = try JSONDecoder().decode(TokenData.self, from: data)
            saveTokens(newTokens)
            return newTokens.accessToken
        } else {
            // ⛔ RTK까지 만료 → userId + createdAt로 재발급
            guard let userId = UserDefaults.standard.string(forKey: "userID"),
                  let createdAt = UserDefaults.standard.string(forKey: "createdAt") else {
                throw AuthError.noUserData
            }

            let url = APIEndpoint.getGuestToken.url()
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["userId": userId, "createdAt": createdAt])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw AuthError.tokenRefreshFailed
            }
            let newTokens = try JSONDecoder().decode(TokenData.self, from: data)
            saveTokens(newTokens)
            return newTokens.accessToken
        }
    }

    private func saveTokens(_ tokens: TokenData) {
        KeychainHelper.standard.save(tokens.accessToken, service: "accessToken", account: "pawcus")
        KeychainHelper.standard.save(tokens.refreshToken, service: "refreshToken", account: "pawcus")
    }
}
