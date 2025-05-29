//
//  Color+Hex.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation
import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            self = Color(red: r, green: g, blue: b)
        default:
            return nil
        }
    }
}
