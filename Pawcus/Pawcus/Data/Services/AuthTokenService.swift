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

    func getAccessToken() -> String {
        if let accessToken = KeychainHelper.standard.read(service: "com.pawcus.token", account: "accessToken"){
            return accessToken
        } else {
            return ""
        }
    }

    func refreshAccessTokenForGuest() async throws {
        if let refreshToken = KeychainHelper.standard.read(service: "com.pawcus.token", account: "refreshToken") {
            // 🔁 RTK로 토큰 재발급
            let url = APIEndpoint.tokenRefresh.url()
            var request = URLRequest(url: url)
            request.httpMethod = APIEndpoint.tokenRefresh.method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["refreshToken": refreshToken])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,(200...299).contains(http.statusCode) else {
                throw AuthError.tokenRefreshFailed
            }
            let newTokens = try JSONDecoder().decode(TokenData.self, from: data)
            saveTokens(newTokens)
        } else {
            // ⛔ RTK까지 만료 → userId + createdAt로 재발급
            guard let userId = UserDefaults.standard.string(forKey: "userId"),
                  let createdAt = UserDefaults.standard.string(forKey: "createdAt") else {
                throw AuthError.noUserData
            }

            let url = APIEndpoint.getGuestToken.url()
            var request = URLRequest(url: url)
            request.httpMethod = APIEndpoint.getGuestToken.method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["userId": userId, "createdAt": createdAt])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw AuthError.tokenRefreshFailed
            }
            let newTokens = try JSONDecoder().decode(ServerResponse<TokenData>.self, from: data)
            saveTokens(newTokens.data!)
        }
    }

    private func saveTokens(_ tokens: TokenData) {
        KeychainHelper.standard.save(tokens.accessToken, service: "com.pawcus.token", account: "accessToken")
        KeychainHelper.standard.save(tokens.refreshToken, service: "com.pawcus.token", account: "refreshToken")
    }
}
