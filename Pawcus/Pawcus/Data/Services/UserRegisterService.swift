//
//  UserRegisterService.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/23/25.
//

import Foundation

final class UserRegisterService {
    private let session: URLSession
    private let userInfoService: UserInfoService
    
    init(session: URLSession = .shared, userInfoService: UserInfoService = UserInfoService()) {
        self.session = session
        self.userInfoService = userInfoService
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
    
    func registerGuest(uuid: String) async throws  {
        let endpoint = APIEndpoint.registerGuest
        let url = endpoint.url()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": uuid]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(ServerResponse<TokenData>.self, from: data)
        guard result.isSuccess, let tokenData = result.data else {
            throw NSError(domain: "UserRegisterService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        
        KeychainHelper.standard.save(tokenData.accessToken,
                                     service: "com.pawcus.token",
                                     account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken,
                                     service: "com.pawcus.token",
                                     account: "refreshToken")
        await fetchAndUpdateUserInfo()
    }
    
    /// 소셜 로그인 회원 등록
    func registerSocialUser(accessToken: String) async throws -> TokenData {
        let endpoint = APIEndpoint.loginSocialUser
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
        
        KeychainHelper.standard.save(tokenData.accessToken,
                                     service: "com.pawcus.token",
                                     account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken,
                                     service: "com.pawcus.token",
                                     account: "refreshToken")

        await fetchAndUpdateUserInfo()
        
        return tokenData
    }
    
    func getGuestToken() async throws -> TokenData {
        guard let userId = UserDefaults.standard.string(forKey: .userId),
              let createdAt = UserDefaults.standard.string(forKey: .createdAt) else {
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
        
        KeychainHelper.standard.save(tokenData.accessToken, service: "com.pawcus.token", account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken, service: "com.pawcus.token", account: "refreshToken")
        
        await fetchAndUpdateUserInfo()
        return tokenData
    }
    
    /// 닉네임 업데이트
    func updateNickname(_ newNickname: String) async throws -> Bool {
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
        return true 
    }
    
    /// 사용자 정보를 가져와서 닉네임을 로컬에 저장
    private func fetchAndUpdateUserInfo() async {
        do {
            let userInfoResponse = try await userInfoService.fetchUserInfo()
            if let userInfo = userInfoResponse.data {
                // 닉네임이 있으면 UserDefaults에 저장
                if !userInfo.nickname.isEmpty {
                    UserDefaults.standard.set(userInfo.nickname, forKey: .userNickname)
                    print("User nickname saved: \(userInfo.nickname)")
                } else {
                    print("User nickname is empty, will show username prompt")
                }
                
                // 사용자 ID도 저장
                UserDefaults.standard.set(userInfo.userId, forKey: .userId)
            }
        } catch {
            print("Failed to fetch user info: \(error)")
        }
    }
}
