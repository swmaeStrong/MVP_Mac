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
    
    func registerGuest(nickname: String) async throws {
        if try await repository.registerGuest(nickname: nickname) {
            try await repository.getGuestToken()
        }
    }
}
