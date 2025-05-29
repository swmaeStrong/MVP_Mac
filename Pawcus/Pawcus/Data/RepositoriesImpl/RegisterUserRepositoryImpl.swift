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
    
    func registerUser(nickname: String) async throws  {
        let uuid = UUID().uuidString
        let success = try await service.registerUser(uuid: uuid, nickname: nickname)
        if success {
            @AppStorage("userNickname") var savedNickname: String = ""
            @AppStorage("userID") var savedUserID: String = ""
            savedNickname = nickname
            savedUserID = uuid
        }
    }
}
