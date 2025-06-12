//
//  ProfileView.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//

import SwiftUI
import Factory
import Sparkle

struct ProfileView: View {
    @State private var isEditingNickname: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @AppStorage("lastRecordedDate") private var storedDate: String = ""
    @Environment(\.modelContext) private var context
    @Injected(\.appLogLocalDataSource) private var appLogLocalDataSource
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 헤더
                profileHeader
                
                // 계정 정보 섹션
                accountSection
                
                // 앱 정보 섹션
                appSection
                
                // 위험 구역
                dangerZone
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $isEditingNickname) {
            UserNamePromptView()
        }
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // 프로필 아이콘
            ZStack {
                Circle()
                    .fill(indigoColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text(userNickname.prefix(2).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(indigoColor)
            }
            
            // 닉네임
            HStack(spacing: 8) {
                Text(userNickname)
                    .font(.system(size: 24, weight: .semibold))
                
                Button(action: { isEditingNickname = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(indigoColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("계정 정보")
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "person.circle.fill",
                    title: "닉네임",
                    value: userNickname,
                    action: { isEditingNickname = true }
                )
                
                Divider()
                    .padding(.leading, 44)
                
                settingRow(
                    icon: "crown.fill",
                    title: "구독 상태",
                    value: "Free Plan",
                    valueColor: .secondary
                )
                
                Divider()
                    .padding(.leading, 44)
                
                settingRow(
                    icon: "clock.fill",
                    title: "오늘 사용 시간",
                    value: formatTime(storedSeconds),
                    valueColor: indigoColor
                )
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - App Section
    private var appSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("앱 정보")
            
            VStack(spacing: 0) {
                Button(action: {
                    AppDelegate.shared.updaterController?.checkForUpdates(nil)
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(indigoColor)
                            .frame(width: 24)
                        
                        Text("업데이트 확인")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, 44)
                
                settingRow(
                    icon: "info.circle.fill",
                    title: "버전",
                    value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                    valueColor: .secondary
                )
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("기타")
            
            Button(action: { showingLogoutAlert = true }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("로그아웃")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
    
    private func settingRow(
        icon: String,
        title: String,
        value: String,
        valueColor: Color = .primary,
        action: (() -> Void)? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(indigoColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text(value)
                            .font(.system(size: 13))
                            .foregroundColor(valueColor)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(valueColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
    
    private func performLogout() {
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
}

#Preview {
    ProfileView()
}
