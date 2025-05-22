//
//  MVP_MacOSApp.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

@main
struct MVP_MacOSApp: App {
    init() {
        ensureAccessibilityPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [AppLogEntity.self])
    }
}
