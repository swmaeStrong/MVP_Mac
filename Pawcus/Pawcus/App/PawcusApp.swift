//
//  MVP_MacOSApp.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI
import Supabase

@main
struct PawcusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var dailyWorkTimeStore = DailyWorkTimeStore()
    init() {
        ensureAccessibilityPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dailyWorkTimeStore)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .modelContainer(for: [AppLogEntity.self])
    }
}

func ensureAccessibilityPermission() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    let accessEnabled = AXIsProcessTrustedWithOptions(options)

    if !accessEnabled {
        print("⚠️ 손쉬운 사용 권한이 필요합니다. 설정에서 앱을 허용해주세요.")
    } else {
        print("✅ 손쉬운 사용 권한 확인됨")
    }
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: AppConfig.supabaseURL)!,
    supabaseKey: AppConfig.supabaseKey,
    options: .init(
        auth: .init(redirectToURL: AppConfig.redirectToURL),
        global: .init(logger: ConsoleLogger())
    )
)
