//
//  UserRegisterService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/23/25.
//

import Foundation

final class UserRegisterService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// 닉네임의 중복을 검증하는 로직
    func isNicknameDuplicated(_ nickname: String) async throws -> Bool {
        let endpoint = APIEndpoint.checkNickname(nickname: nickname)
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<Bool>.self, from: data)
        guard result.isSuccess else {
            throw NSError(domain: "UserRegisterService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return result.data ?? true
    }
    
    func registerGuest(uuid: String, nickname: String) async throws -> UserData {
        let endpoint = APIEndpoint.registerGuest
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": uuid, "nickname": nickname]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<UserData>.self, from: data)
        guard result.isSuccess, let userData = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return userData
    }
    
    /// 소셜 로그인 회원 등록
    func registerSocialUser(accessToken: String) async throws -> TokenData {
        let endpoint = APIEndpoint.registerSocialUser
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["accessToken": accessToken]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<TokenData>.self, from: data)
        guard result.isSuccess, let tokenData = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return tokenData
    }
    
    func getGuestToken() async throws -> TokenData {
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              let createdAt = UserDefaults.standard.string(forKey: "createdAt") else {
            throw NSError(domain: "UserRegisterService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing userID or createdAt in UserDefaults"])
        }

        let endpoint = APIEndpoint.getGuestToken
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["userId": userId, "createdAt": createdAt]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(ServerResponse<TokenData>.self, from: data)
        guard let tokenData = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }

        return tokenData
    }
    
    /// 닉네임 업데이트
    func updateNickname(_ newNickname: String) async throws {
        let endpoint = APIEndpoint.updateNickname
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.addJSONHeader()
        request.addBearerToken()
        let body = ["nickname": newNickname]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(ServerResponse<SimpleUserData>.self, from: data)
        guard result.isSuccess, let _ = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
    }
}
