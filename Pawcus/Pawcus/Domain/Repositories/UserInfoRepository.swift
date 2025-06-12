import Foundation

protocol UserInfoRepository {
    func fetchUserInfo() async throws -> UserInfo
    func saveUserInfo(_ userInfo: UserInfo) async throws
}