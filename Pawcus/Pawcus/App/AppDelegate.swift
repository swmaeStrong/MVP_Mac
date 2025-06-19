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
        
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        
        // 메뉴바 추가 (Sparkle UI 표시용)
        setupMenuBar()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updaterController?.updater.checkForUpdatesInBackground()
        }
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        
        // App 메뉴
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "Pawcus")
        
        // Check for Updates 메뉴 항목
        let updateMenuItem = NSMenuItem(
            title: "Check for Updates...",
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        updateMenuItem.target = self
        
        appMenu.addItem(updateMenuItem)
        appMenu.addItem(NSMenuItem.separator())
        
        // Quit 메뉴 항목
        let quitMenuItem = NSMenuItem(
            title: "Quit Pawcus",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitMenuItem)
        
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }
    
    @objc private func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
}
