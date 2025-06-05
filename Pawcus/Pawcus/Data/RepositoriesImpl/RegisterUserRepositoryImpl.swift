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
        KeychainHelper.standard.save(tokenData.accessToken, service: "com.pawcus.token", account: "accessToken")
        KeychainHelper.standard.save(tokenData.refreshToken, service: "com.pawcus.token", account: "refreshToken")
    }

}

import Security

final class KeychainHelper {
    static let standard = KeychainHelper()

    private init() {}

    func save(_ data: String, service: String, account: String) {
        let data = Data(data.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete any existing item
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess else {
            return nil
        }

        guard let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
