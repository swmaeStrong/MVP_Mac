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
    
    private var timer: Timer?
    private var lastTitle: String?
    private var lastAppName: String?
    private var lastTimestamp: Date?
    private var lastFlushDate: Date?
    private var lastUrl: String?
    private var appLogLocalDataSource: AppLogLocalDataSource
    
    init(appLogLocalDataSource: AppLogLocalDataSource) {
        self.appLogLocalDataSource = appLogLocalDataSource
    }

    /// 1초에 한번씩 보고있는 타이틀을 로깅해 SwiftData에 저장
    func startLogging() {
        lastFlushDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let log = self.getActiveAppInfo() else { return }

            let now = Date()
            if log.title != self.lastTitle || log.url != self.lastUrl {
                // 앱 전환 감지
                let newAppName = log.app
                let newTitle = log.title
                let newUrl = log.url
                let duration = now.timeIntervalSince(self.lastTimestamp ?? now)
                // 이전 세션 기록
                if  let prevApp = self.lastAppName,
                    let prevTitle = self.lastTitle,
                    let prevUrl = self.lastUrl {
                    let sessionLog = UsageLog(timestamp: now, duration: duration, title: prevTitle, app: prevApp, url: prevUrl)
                    try? self.appLogLocalDataSource.insertAppLog(sessionLog)
                }
                // 상태 업데이트
                self.lastAppName = newAppName
                self.lastTitle = newTitle
                self.lastTimestamp = now
                self.lastFlushDate = now
                self.lastUrl = newUrl
            } else if let lastFlush = self.lastFlushDate, now.timeIntervalSince(lastFlush) >= 10 {
                // 10초 경과시 강제 저장
                if let prevApp = self.lastAppName,
                   let prevTitle = self.lastTitle,
                   let lastTimestamp = self.lastTimestamp,
                    let prevUrl = self.lastUrl {
                    let duration = now.timeIntervalSince(lastTimestamp)
                    let sessionLog = UsageLog(timestamp: now, duration: duration, title: prevTitle, app: prevApp, url: prevUrl)
                    try? self.appLogLocalDataSource.insertAppLog(sessionLog)
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
        lastUrl = nil
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
        
        var finalTitle: String
        var finalUrl: String
        
        // 웹 브라우저인 경우: title과 URL 모두 가져오기
        if isWebBrowser(appName) {
            let browserInfo = getBrowserInfo(appName: appName, pid: pid)
            finalTitle = browserInfo.title
            finalUrl = browserInfo.url
        } else {
            // 일반 앱인 경우: title은 윈도우 제목, domain은 ""
            finalTitle = titleString
            finalUrl = ""
        }
        
        return UsageLog(
            timestamp: .now, 
            duration: 0, 
            title: finalTitle, 
            app: appName,
            url: finalUrl
        )
    }
    
    /// 웹 브라우저인지 확인하는 메서드
    private func isWebBrowser(_ appName: String) -> Bool {
        let browsers = ["Safari", "Google Chrome", "Arc", "Firefox", "Microsoft Edge", "Opera"]
        return browsers.contains { browser in
            appName.lowercased().contains(browser.lowercased())
        }
    }
    
    /// 브라우저에서 현재 제목과 URL을 가져오는 메서드
    private func getBrowserInfo(appName: String, pid: pid_t) -> (title: String, url: String) {
        let urlScript: String
        let titleScript: String
        
        switch appName.lowercased() {
        case let name where name.contains("safari"):
            urlScript = "tell application \"Safari\" to return URL of current tab of front window"
            titleScript = "tell application \"Safari\" to return name of current tab of front window"
        case let name where name.contains("chrome"):
            urlScript = "tell application \"Google Chrome\" to return URL of active tab of front window"
            titleScript = "tell application \"Google Chrome\" to return title of active tab of front window"
        case let name where name.contains("arc"):
            urlScript = "tell application \"Arc\" to return URL of active tab of front window"
            titleScript = "tell application \"Arc\" to return title of active tab of front window"
        case let name where name.contains("firefox"):
            urlScript = "tell application \"Firefox\" to return URL of active tab of front window"
            titleScript = "tell application \"Firefox\" to return title of active tab of front window"
        case let name where name.contains("edge"):
            urlScript = "tell application \"Microsoft Edge\" to return URL of active tab of front window"
            titleScript = "tell application \"Microsoft Edge\" to return title of active tab of front window"
        default:
            return (title: "", url: "")
        }
        
        let url = executeAppleScript(urlScript) ?? ""
        let title = executeAppleScript(titleScript) ?? ""
        
        return (title: title, url: url)
    }
    
    /// AppleScript 실행 메서드
    private func executeAppleScript(_ script: String) -> String? {
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            let errorCode = error["NSAppleScriptErrorNumber"] as? Int
            if errorCode == -1743 {
                print("⚠️ AppleScript 권한이 필요합니다. 시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 Pawcus가 브라우저를 제어할 수 있도록 허용해주세요.")
                DispatchQueue.main.async {
                    self.showAutomationPermissionAlert()
                }
            } else {
                print("❌ AppleScript Error: \(error)")
            }
            return nil
        }
        
        return result.stringValue
    }
    
    /// 자동화 권한 알림을 표시하는 메서드
    private func showAutomationPermissionAlert() {
        guard let _ = NSApplication.shared.delegate as? NSObject else { return }
        
        let alert = NSAlert()
        alert.messageText = "브라우저 자동화 권한 필요"
        alert.informativeText = "웹 브라우저에서 현재 URL을 추적하려면 자동화 권한이 필요합니다.\n\n시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 Pawcus가 Safari, Chrome 등을 제어할 수 있도록 허용해주세요."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "시스템 설정 열기")
        alert.addButton(withTitle: "나중에")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openSystemPreferences()
        }
    }
    
    /// 시스템 설정 열기 메서드
    private func openSystemPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
        NSWorkspace.shared.open(url)
    }
}
