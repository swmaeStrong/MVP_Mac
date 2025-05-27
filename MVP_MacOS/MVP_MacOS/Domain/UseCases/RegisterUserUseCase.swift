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
    
    func registerUser(nickname: String) async throws {
        try await repository.registerUser(nickname: nickname)
    }
}
