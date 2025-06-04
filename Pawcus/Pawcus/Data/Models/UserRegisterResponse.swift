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

struct ServerNicknameResponse: Codable {
    let isSuccess: Bool
    let code: String?
    let message: String?
    let data: Bool?
}

struct ServerResponse: Codable {
    let isSuccess: Bool
    let code: String?
    let message: String?
    let data: UserData?
}
