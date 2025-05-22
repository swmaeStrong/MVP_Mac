//
//  AccessibilityPermission.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/21/25.
//

import Foundation
import ApplicationServices

func ensureAccessibilityPermission() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    let accessEnabled = AXIsProcessTrustedWithOptions(options)

    if !accessEnabled {
        print("⚠️ 손쉬운 사용 권한이 필요합니다. 설정에서 앱을 허용해주세요.")
    } else {
        print("✅ 손쉬운 사용 권한 확인됨")
    }
}
