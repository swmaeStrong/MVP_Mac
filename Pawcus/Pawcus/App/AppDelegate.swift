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

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        
        // Create a standard user driver for update UI
        let userDriver = SPUStandardUserDriver(hostBundle: Bundle.main, delegate: nil)
        
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: userDriver
        )
        
        // 앱 시작 시 업데이트 확인 (선택사항)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updaterController?.updater.checkForUpdatesInBackground()
        }
    }
}
