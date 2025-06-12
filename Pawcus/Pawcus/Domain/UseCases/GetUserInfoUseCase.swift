import Foundation

final class GetUserInfoUseCase {
    private let userInfoRepository: UserInfoRepository
    
    init(userInfoRepository: UserInfoRepository) {
        self.userInfoRepository = userInfoRepository
    }
    
    func execute() async throws {
        let userInfo = try await userInfoRepository.fetchUserInfo()
        try await userInfoRepository.saveUserInfo(userInfo)
    }
}
