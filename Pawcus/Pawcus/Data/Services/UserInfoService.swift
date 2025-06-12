import Foundation
import Supabase

final class UserInfoService: ObservableObject {
    
    func fetchUserInfo() async throws -> UserInfoResponseDTO {
        let token = TokenManager.getAccessToken()
        let endpoint = APIEndpoint.getUserInfo
        var request = URLRequest(url: endpoint.url())
        request.httpMethod = endpoint.method
        request.addJSONHeader()
        request.addBearerToken()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "UserInfoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("UserInfo API Response Status: \(httpResponse.statusCode)")
        print("UserInfo API Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "UserInfoService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
        }
        
        do {
            let userInfoResponse = try JSONDecoder().decode(UserInfoResponseDTO.self, from: data)
            return userInfoResponse
        } catch {
            print("JSON Decoding Error: \(error)")
            throw error
        }
    }
}
