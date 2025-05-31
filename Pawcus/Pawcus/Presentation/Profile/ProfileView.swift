//
//  SettingView.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//

import SwiftUI
import Factory

struct ProfileView: View {
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @AppStorage("lastRecordedDate") private var storedDate: String = ""
    @Environment(\.modelContext) private var context
    @Injected(\.appLogLocalDataSource) private var appLogLocalDataSource

    var body: some View {
        VStack(spacing: 20) {
            Text("닉네임: \(userNickname)")
                .font(.title2)
            Text("Pro Plan: false")
                .foregroundColor(.gray)

            Button("로그아웃") {
                userNickname = ""
                userID = ""
                storedSeconds = 0
                storedDate = ""
                Task {
                    try appLogLocalDataSource.removeAllAppLogs(context: context)
                }
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
