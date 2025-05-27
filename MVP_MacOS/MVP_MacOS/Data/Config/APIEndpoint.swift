//
//  APIEndpoint.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

enum APIEndpoint {
    static let baseURL = URL(string: AppConfig.baseURL)!
    
    case checkNickname(nickname: String)
    case registerUser
    case uploadLog

    var path: String {
        switch self {
        case .checkNickname:
            return "/guest-users/is-nickname-duplicated"
        case .registerUser:
            return "/guest-users"
        case .uploadLog:
            return "/usage-log"
        }
    }

    var method: String {
        switch self {
        case .checkNickname: return "GET"
        case .registerUser: return "POST"
        case .uploadLog: return "POST"
        }
    }

    func url() -> URL {
        switch self {
        case .checkNickname(let nickname):
            var components = URLComponents(url: APIEndpoint.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "nickname", value: nickname)]
            return components.url!
        case .registerUser:
            return APIEndpoint.baseURL.appendingPathComponent(path)
        case .uploadLog:
            return APIEndpoint.baseURL.appendingPathComponent(path)
        }
    }
}
