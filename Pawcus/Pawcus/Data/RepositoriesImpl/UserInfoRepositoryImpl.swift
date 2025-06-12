import Foundation

final class UserInfoRepositoryImpl: UserInfoRepository {
    private let userInfoService: UserInfoService
    
    init(userInfoService: UserInfoService) {
        self.userInfoService = userInfoService
    }
    
    func fetchUserInfo() async throws -> UserInfo {
        return try await userInfoService.fetchUserInfo()
    }
    
    func saveUserInfo(_ userInfo: UserInfo) async throws {
        UserDefaults.standard.set(userInfo.userId, forKey: .userId)
        
        if let nickname = userInfo.nickname {
            UserDefaults.standard.set(nickname, forKey: .userNickname)
        }
        
        UserDefaults.standard.set(true, forKey: .isLoggedIn)
    }
}
