//
//  RegisterUserUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation
import SwiftUI

final class RegisterUserUseCase {
    
    private let service: UserRegisterService
    
    init(service: UserRegisterService) {
        self.service = service
    }
    
    func isNicknameValid(nickname: String) async throws -> Bool {
        let isValid = try await !service.isNicknameDuplicated(nickname)
        return isValid
    }
    
    func register(uuid: String, nickname: String) async throws  {
        let success = try await service.registerUser(uuid: uuid, nickname: nickname)
        if success {
            @AppStorage("userNickname") var savedNickname: String = ""
            @AppStorage("userID") var savedUserID: String = ""
            savedNickname = nickname
            savedUserID = uuid
        }
    }
}
