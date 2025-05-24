//
//  UserRegisterService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/23/25.
//

import Foundation

final class UserRegisterService {
    private let baseURL = URL(string: "http://3.39.105.127")!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct ServerResponse: Codable {
        let isSuccess: Bool
        let code: String?
        let message: String?
        let data: Bool?
    }
    
    /// 닉네임의 중복을 검증하는 로직
    func isNicknameDuplicated(_ nickname: String) async throws -> Bool {
        var components = URLComponents(url: baseURL.appendingPathComponent("/guest-users/is-nickname-duplicated"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "nickname", value: nickname)]
        let url = components.url!
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse.self, from: data)
        guard result.isSuccess else {
            throw NSError(domain: "UserRegisterService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return result.data ?? true
    }
    
    func registerUser(uuid: String, nickname: String) async throws -> Bool {
        let url = baseURL.appendingPathComponent("/guest-users")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["deviceId": uuid, "nickname": nickname]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse.self, from: data)
        guard result.isSuccess else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return result.isSuccess
    }
}
