//
//  AppDelegate.swift
//  Pawcus
//
//  Created by 김정원 on 5/30/25.
//

import Foundation
import Sparkle
import AppKit

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
    }
}
