//
//  RegisterUserUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

import Foundation

final class RegisterUserUseCase {
    
    private let service: UserRegisterService
    
    init(service: UserRegisterService) {
        self.service = service
    }
    
    func isNicknameValid(nickname: String) async throws -> Bool {
        let isValid = try await !service.isNicknameDuplicated(nickname)
        return isValid
    }
    
    func register(nickname: String, uuid: String) async throws -> Bool {
//        let valid = try await validate(nickname: nickname)
//        guard valid else {
//            throw RegistrationError.duplicateNickname
//        }
//        try await service.registerUser(nickname: nickname, uuid: uuid)
        return false
    }
}
