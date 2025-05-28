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
    case getCategories
    case getUserRanks(category: String, page: Int?, size: Int?, date: String)

    var path: String {
        switch self {
        case .checkNickname:
            return "/guest-users/is-nickname-duplicated"
        case .registerUser:
            return "/guest-users"
        case .uploadLog:
            return "/usage-log"
        case .getCategories:
            return "/category"
        case .getUserRanks(let category, _, _, _):
            return "/leaderboard/\(category)"
        }
    }

    var method: String {
        switch self {
        case .checkNickname: return "GET"
        case .registerUser: return "POST"
        case .uploadLog: return "POST"
        case .getCategories: return "GET"
        case .getUserRanks: return "GET"
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
        case .getCategories:
            return APIEndpoint.baseURL.appendingPathComponent(path)
        case .getUserRanks(let category, let page, let size, let date):
            var components = URLComponents(url: APIEndpoint.baseURL.appendingPathComponent("/leaderboard/\(category)"), resolvingAgainstBaseURL: false)!
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
        }
    }
}
