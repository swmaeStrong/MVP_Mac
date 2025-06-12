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
    private let infoService: UserInfoService = UserInfoService()
    
    init(service: UserRegisterService) {
        self.service = service
    }
    
    func checkNicknameAvailability(nickname: String) async throws -> Bool {
        let isValid = try await !service.isNicknameDuplicated(nickname)
        return isValid
    }
    
    func updateNickname(_ nickname: String) async throws {
        if try await service.updateNickname(nickname) {
            UserDefaults.standard.set(nickname, forKey: .userNickname)
        }
    }
    
    func registerGuest() async throws -> Bool {
        let uuid = UUID().uuidString
        let tokenData = try await service.registerGuest(uuid: uuid)
        saveToken(tokenData: tokenData)
        UserDefaults.standard.set(uuid, forKey: .userId)
        return true
    }
    
    func registerSocialUser(accessToken: String) async throws {
       let tokenData = try await service.registerSocialUser(accessToken: accessToken)
        saveToken(tokenData: tokenData)
    }
    
    func saveToken(tokenData: TokenData) {
        TokenManager.saveTokens(tokenData)
    }
}
