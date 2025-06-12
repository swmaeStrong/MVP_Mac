import Foundation

struct UserInfoResponseDTO: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: UserInfoDataDTO?
}

struct UserInfoDataDTO: Codable {
    let userId: String
    let nickname: String
}