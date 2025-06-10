//
//  UserRegisterResponse.swift
//  Pawcus
//
//  Created by 김정원 on 6/3/25.
//

import Foundation

struct UserData: Codable {
    let userId: String
    let nickname: String
    let createdAt: String
}

struct SimpleUserData: Codable {
    let userId: String
    let nickname: String
}

struct TokenData: Codable {
    let accessToken: String
    let refreshToken: String
}
