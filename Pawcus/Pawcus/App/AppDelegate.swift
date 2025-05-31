//
//  AppDelegate.swift
//  Pawcus
//
//  Created by 김정원 on 5/30/25.
//

import Foundation
import Sparkle
import AppKit
import Supabase

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    static var shared: AppDelegate!
    var updaterController: SPUStandardUpdaterController?
    var supabaseClient: SupabaseClient!

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        
        // Supabase 설정
        supabaseClient = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseKey
        )
    }
}
