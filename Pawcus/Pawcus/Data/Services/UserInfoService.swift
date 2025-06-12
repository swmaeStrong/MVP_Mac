import Foundation
import Supabase

final class UserInfoService: ObservableObject {
    
    func fetchUserInfo() async throws -> UserInfo {
        let endpoint = APIEndpoint.getUserInfo
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method
        request.addJSONHeader()
        request.addBearerToken()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "UserInfoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "UserInfoService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
        }
        
        let result = try JSONDecoder().decode(ServerResponse<UserInfo>.self, from: data)
        guard result.isSuccess, let userInfo = result.data else {
            throw NSError(domain: "UserRegisterService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: result.message ?? "Unknown error"])
        }
        
        return userInfo
    }
}
