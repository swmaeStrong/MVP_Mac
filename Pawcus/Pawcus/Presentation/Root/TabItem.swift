//
//  TabItem.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation

enum Tab: String, CaseIterable, Identifiable, Hashable {
    case leaderboard = "LeaderBoard"
    case analysis = "Analysis"
    case profile = "Profile"
    case web = "web"
    
    var imageName: String {
        switch self {
        case .leaderboard: return "chart.bar.fill"
        case .analysis: return "magnifyingglass.circle.fill"
        case .profile: return "person.crop.circle.fill"
        case .web: return "plus.circle.fill"
        }
    }
    
    var id: String { rawValue }
}