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
    
    init(service: UserRegisterService) {
        self.service = service
    }
    
    func checkNicknameAvailability(nickname: String) async throws -> Bool {
        let isValid = try await !service.isNicknameDuplicated(nickname)
        return isValid
    }
    
    func registerUser(nickname: String) async throws -> Bool {
        let uuid = UUID().uuidString
        let userData = try await service.registerUser(uuid: uuid, nickname: nickname)
        UserDefaults.standard.set(nickname, forKey: "userNickname")
        UserDefaults.standard.set(uuid, forKey: "userId")
        UserDefaults.standard.set(userData.createdAt, forKey: "createdAt")
        return true
    }
    
    func getGuestToken() async throws {
        let tokenData = try await service.getGuestToken()
        print("토큰: \(tokenData.accessToken)")
        UserDefaults.standard.set(tokenData.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(tokenData.refreshToken, forKey: "refreshToken")
    }

}
