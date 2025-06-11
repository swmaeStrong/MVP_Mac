//
//  SettingView.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//

import SwiftUI
import Factory
import Sparkle

struct ProfileView: View {
    @State private var isEditingNickname: Bool = false
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @AppStorage("lastRecordedDate") private var storedDate: String = ""
    @Environment(\.modelContext) private var context
    @Injected(\.appLogLocalDataSource) private var appLogLocalDataSource

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("닉네임: \(userNickname)")
                    .font(.title2)
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        isEditingNickname = true
                    }
            }
            Text("Pro Plan: false")
                .foregroundColor(.gray)
            Button("업데이트 확인") {
                AppDelegate.shared.updaterController?.checkForUpdates(nil)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            Button("로그아웃") {
                
                Task {
                    await SupabaseAuthService().logout()
                    try appLogLocalDataSource.removeAllAppLogs()
                }
                let defaults = UserDefaults.standard
                defaults.remove(.userNickname)
                defaults.remove(.userId)
                defaults.remove(.isLoggedIn)
                defaults.remove(.dailyWorkSeconds)
                defaults.remove(.lastRecordedDate)
                KeychainHelper.standard.save("", service: "com.pawcus.token", account: "accessToken")
                KeychainHelper.standard.save("", service: "com.pawcus.token", account: "refreshToken")
            }
            .foregroundColor(.red)
        }
        .padding()
        .sheet(isPresented: $isEditingNickname) {
            UserNamePromptView()
        }
    }
}

#Preview {
    ProfileView()
}
