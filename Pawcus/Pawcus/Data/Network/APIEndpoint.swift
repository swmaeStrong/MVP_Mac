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
    case registerGuest
    case registerSocialUser
    case uploadLog
    case getCategories
    case getUserRanksByCategory(category: String, page: Int?, size: Int?, date: String)
    case getUserTop10Ranks
    case getUserLogs(userId: String, date: String)
    case getGuestToken
    case tokenRefresh
    case updateNickname
    
    var path: String {
        switch self {
        case .checkNickname:
            return "/user/nickname/check"
        case .registerGuest:
            return "/guest-users"
        case .registerSocialUser:
            return "/auth/social-login"
        case .uploadLog:
            return "/usage-log"
        case .getCategories:
            return "/category"
        case .getUserRanksByCategory(let category, _, _, _):
            return "/leaderboard/\(category)/daily"
        case .getUserTop10Ranks:
            return "leaderboard/top-users"
        case .getUserLogs:
            return "usage-log"
        case .getGuestToken:
            return "/guest-users/get-token"
        case .tokenRefresh:
            return "/auth/refresh"
        case .updateNickname:
            return "guest-users/nickname"
        }
    }

    var method: String {
        switch self {
        case .checkNickname: return "GET"
        case .registerGuest: return "POST"
        case .registerSocialUser: return "POST"
        case .uploadLog: return "POST"
        case .getCategories: return "GET"
        case .getUserRanksByCategory: return "GET"
        case .getUserTop10Ranks: return "GET"
        case .getUserLogs: return "GET"
        case .getGuestToken: return "POST"
        case .tokenRefresh: return "POST"
        case .updateNickname: return "PATCH"
        }
    }

    func url() -> URL {
        switch self {
        case .checkNickname(let nickname):
            var components = URLComponents(url: APIEndpoint.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "nickname", value: nickname)]
            return components.url!
            
        case .getUserRanksByCategory(let category, let page, let size, let date):
            var components = URLComponents(url: APIEndpoint.baseURL.appendingPathComponent("/leaderboard/\(category)/daily"), resolvingAgainstBaseURL: false)!
            var items: [URLQueryItem] = []
            if let page = page {
                items.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let size = size {
                items.append(URLQueryItem(name: "size", value: "\(size)"))
            }
            items.append(URLQueryItem(name: "date", value: date))
            components.queryItems = items
            return components.url!
        case .getUserLogs(userId: let userId, date: let date):
            var components = URLComponents(
                url: APIEndpoint.baseURL.appendingPathComponent(path),
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "date", value: date)
            ]
            return components.url!
        default:
            return APIEndpoint.baseURL.appendingPathComponent(path)
        }
    }
}
