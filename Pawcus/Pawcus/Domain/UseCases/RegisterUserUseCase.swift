//
//  RegisterUserUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

final class RegisterUserUseCase {
    private let repository: RegisterUserRepository
    
    init(repository: RegisterUserRepository) {
        self.repository = repository
    }
    
    func checkNicknameAvailability(nickname: String) async throws -> Bool {
        return try await repository.checkNicknameAvailability(nickname: nickname)
    }
    
    func registerGuest() async throws {
        if try await repository.registerGuest() {
            try await repository.getGuestToken()
        }
    }
    
    func registerSocialUser(accessToken: String) async throws {
        try await repository.registerSocialUser(accessToken: accessToken)
    }
}
