//
//  RegisterUserRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

protocol RegisterUserRepository {
    func checkNicknameAvailability(nickname: String) async throws -> Bool
    func registerGuest(nickname: String) async throws -> Bool
    func registerSocialUser(accessToken: String) async throws
    func getGuestToken() async throws
}
