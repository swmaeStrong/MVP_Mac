//
//  AppUsageLogger.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/21/25.
//

import Foundation
import AppKit
import SwiftData

/// 앱의 로그를 기록하는 클래스
class AppUsageLogger {
    
    private var context: ModelContext?
    private var timer: Timer?
    private var lastTitle: String?
    private var lastTimestamp: Date?
    
    func configure(context: ModelContext) {
        self.context = context
        startLogging()
    }

    /// 1초에 한번씩 보고있는 타이틀을 로깅해 SwiftData에 저장
    private func startLogging() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let log = self.getActiveAppInfo() else { return }

            // 창 변화가 있을 때만 로그 기록
            if log.title != self.lastTitle {
                print("[CHANGED] \(log.timestamp): \(log.app) - \(log.title)")
                self.lastTitle = log.title
                if let context = self.context {
                    let now = Date()
                    let duration = now.timeIntervalSince(self.lastTimestamp ?? now)
                    let log = AppLog(timestamp: now, duration: duration, title: log.title, app: log.app)
                    self.lastTimestamp = now
                    try? SwiftDataManager().saveLog(log, context: context)
                }
            }
        }
    }
    
    /// 현재 보고있는 top title을 추적하는 메서드
    private func getActiveAppInfo() -> AppLog? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let appName = frontmostApp.localizedName else {
            print("❌ frontmostApplication nil")
            return nil
        }

        var titleString = ""
        let pid = frontmostApp.processIdentifier

        let appElement = AXUIElementCreateApplication(pid)
        var winRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &winRef) == .success,
           let unwrappedWinRef = winRef {
            let win = unwrappedWinRef as! AXUIElement
            var titleRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(win, kAXTitleAttribute as CFString, &titleRef) == .success,
               let axTitle = titleRef as? String, !axTitle.isEmpty {
                titleString = axTitle
            }
        }
        return AppLog(timestamp: .now, duration: 0, title: titleString, app: appName)
    }

   
}
