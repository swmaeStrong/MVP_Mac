//
//  UserInfoRepository.swift
//  Pawcus
//
//  Created by 김정원 on 6/12/25.
//

import Foundation

protocol UserInfoRepository {
    func fetchUserInfo() async throws -> UserInfo
    func saveUserInfo(_ userInfo: UserInfo) async throws
}
