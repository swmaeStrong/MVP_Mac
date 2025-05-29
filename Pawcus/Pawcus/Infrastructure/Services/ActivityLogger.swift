//
//  AppUsageLogger.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/21/25.
//

import Foundation
import AppKit
import SwiftData
import Factory

/// 앱의 로그를 기록하는 클래스
final class ActivityLogger {
    
    private var context: ModelContext?
    private var timer: Timer?
    private var lastTitle: String?
    private var lastAppName: String?
    private var lastTimestamp: Date?
    private var lastFlushDate: Date?
    private var appLogLocalDataSource: AppLogLocalDataSource
    
    init(appLogLocalDataSource: AppLogLocalDataSource) {
        self.appLogLocalDataSource = appLogLocalDataSource
    }
    
    func configure(context: ModelContext) {
        self.context = context
        startLogging()
    }

    /// 1초에 한번씩 보고있는 타이틀을 로깅해 SwiftData에 저장
    private func startLogging() {
        lastFlushDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let log = self.getActiveAppInfo() else { return }

            let now = Date()
            if log.title != self.lastTitle {
                // 앱 전환 감지
                let newAppName = log.app
                let newTitle = log.title
                let duration = now.timeIntervalSince(self.lastTimestamp ?? now)
                // 이전 세션 기록
                if let context = self.context,
                   let prevApp = self.lastAppName,
                   let prevTitle = self.lastTitle {
                    let sessionLog = UsageLog(timestamp: now, duration: duration, title: prevTitle, app: prevApp)
                    try? self.appLogLocalDataSource.insertAppLog(sessionLog, context: context)
                }
                // 상태 업데이트
                self.lastAppName = newAppName
                self.lastTitle = newTitle
                self.lastTimestamp = now
                self.lastFlushDate = now
            } else if let lastFlush = self.lastFlushDate, now.timeIntervalSince(lastFlush) >= 10 {
                // 5분 경과시 강제 저장
                if let context = self.context,
                   let prevApp = self.lastAppName,
                   let prevTitle = self.lastTitle,
                   let lastTimestamp = self.lastTimestamp {
                    let duration = now.timeIntervalSince(lastTimestamp)
                    let sessionLog = UsageLog(timestamp: now, duration: duration, title: prevTitle, app: prevApp)
                    try? self.appLogLocalDataSource.insertAppLog(sessionLog, context: context)
                    self.lastFlushDate = now
                    self.lastTimestamp = now
                }
            }
        }
    }
    
    func stopLogging() {
        lastTitle = nil
        lastAppName = nil
        lastTimestamp = nil
        lastFlushDate = nil
        timer?.invalidate()
        timer = nil
    }
    
    /// 현재 보고있는 top title을 추적하는 메서드
    private func getActiveAppInfo() -> UsageLog? {
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
        return UsageLog(timestamp: .now, duration: 0, title: titleString, app: appName)
    }
}
