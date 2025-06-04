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
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<Bool>.self, from: data)
        guard result.isSuccess else {
            throw NSError(domain: "UserRegisterService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return result.data ?? true
    }
    
    /// 서버 리스폰스 구조 변경에 맞춰 수정
    func registerUser(uuid: String, nickname: String) async throws -> UserData {
        let endpoint = APIEndpoint.registerUser
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": uuid, "nickname": nickname]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<UserData>.self, from: data)
        guard result.isSuccess, let userData = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        return userData
    }
}
