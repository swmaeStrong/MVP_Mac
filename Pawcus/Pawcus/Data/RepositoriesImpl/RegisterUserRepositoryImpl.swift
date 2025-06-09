//
//  RegisterUserRepositoryImpl.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation
import SwiftUI

final class RegisterUserRepositoryImpl: RegisterUserRepository {
    
    private let service: UserRegisterService
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    init(service: UserRegisterService) {
        self.service = service
    }
    
    func checkNicknameAvailability(nickname: String) async throws -> Bool {
        let isValid = try await !service.isNicknameDuplicated(nickname)
        return isValid
    }
    
    func registerGuest(nickname: String) async throws -> Bool {
        let uuid = UUID().uuidString
        let userData = try await service.registerGuest(uuid: uuid, nickname: nickname)
        UserDefaults.standard.set(nickname, forKey: "userNickname")
        UserDefaults.standard.set(uuid, forKey: "userId")
        UserDefaults.standard.set(userData.createdAt, forKey: "createdAt")
        isLoggedIn = true
        return true
    }
    
    func registerSocialUser(accessToken: String) async throws {
        let tokenData = try await service.registerSocialUser(accessToken: accessToken)
        // 네트워크 호출 결과로 받은 토큰을 로컬에 저장
        isLoggedIn = true
        KeychainHelper.standard.save(tokenData.accessToken,
                                     service: "com.pawcus.token",
                                     account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken,
                                     service: "com.pawcus.token",
                                     account: "refreshToken")
    }
    
    func getGuestToken() async throws {
        let tokenData = try await service.getGuestToken()
        isLoggedIn = true
        KeychainHelper.standard.save(tokenData.accessToken, service: "com.pawcus.token", account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken, service: "com.pawcus.token", account: "refreshToken")
    }
}
