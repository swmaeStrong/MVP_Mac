//
//  AppCategoryType.swift
//  Pawcus
//
//  Created by 김정원 on 6/18/25.
//

import Foundation

enum AppCategoryType: String, CaseIterable {
    case development
    case llm
    case documentation
    case design
    case videoEditing = "video editing"
    case youtube
    case communication
    case sns
    case entertainment
    case productivity
    case fileManagement = "file management"
    case systemAndUtilities = "system & utilities"
    case game
    case education
    case finance
    case uncategorized

    var colorHex: String {
        switch self {
        case .development: return "#2D9CDB"
        case .llm: return "#9B51E0"
        case .documentation: return "#F2994A"
        case .design: return "#EB5757"
        case .videoEditing: return "#BB6BD9"
        case .youtube: return "#FF0000"
        case .communication: return "#27AE60"
        case .sns: return "#00BFFF"
        case .entertainment: return "#F2C94C"
        case .productivity: return "#56CCF2"
        case .fileManagement: return "#6FCF97"
        case .systemAndUtilities: return "#BDBDBD"
        case .game: return "#F299CA"
        case .education: return "#219653"
        case .finance: return "#333333"
        case .uncategorized: return "#828282"
        }
    }

    var iconName: String {
        switch self {
        case .development: return "chevron.left.forwardslash.chevron.right"
        case .llm: return "brain.head.profile"
        case .documentation: return "doc.text"
        case .design: return "paintbrush"
        case .videoEditing: return "film"
        case .youtube: return "play.rectangle.fill"
        case .communication: return "bubble.left.and.bubble.right"
        case .sns: return "person.2"
        case .entertainment: return "tv"
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .fileManagement: return "folder"
        case .systemAndUtilities: return "gearshape"
        case .game: return "gamecontroller"
        case .education: return "book"
        case .finance: return "dollarsign.circle"
        case .uncategorized: return "questionmark.app"
        }
    }

    init(from rawValue: String) {
        self = AppCategoryType(rawValue: rawValue.lowercased()) ?? .uncategorized
    }
}
