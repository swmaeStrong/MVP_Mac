//
//  RegisterUserUseCase.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/19/25.
//

final class RegisterUserUseCase {
    private let repository: RegisterUserRepository
    private let getUserInfoUseCase: GetUserInfoUseCase
    
    init(repository: RegisterUserRepository, getUserInfoUseCase: GetUserInfoUseCase) {
        self.repository = repository
        self.getUserInfoUseCase = getUserInfoUseCase
    }
    
    func checkNicknameAvailability(nickname: String) async throws -> Bool {
        return try await repository.checkNicknameAvailability(nickname: nickname)
    }
    
    func registerGuest() async throws {
        if try await repository.registerGuest() {
            try await getUserInfoUseCase.execute()
        }
    }
    
    func registerSocialUser(accessToken: String) async throws {
        try await repository.registerSocialUser(accessToken: accessToken)
        try await getUserInfoUseCase.execute()
    }
    
    func updateNickname(_ nickname: String) async throws {
        try await repository.updateNickname(nickname)
    }
}
