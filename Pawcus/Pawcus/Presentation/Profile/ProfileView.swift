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
    @Injected(\.appLogLocalDataSource) private var appLogLocalDataSource
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Account Section
                accountSection
                
                // App Info Section
                appSection
                
                // Danger Zone
                dangerZone
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $isEditingNickname) {
            UserNamePromptView()
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Icon
            ZStack {
                Circle()
                    .fill(indigoColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text(userNickname.prefix(2).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(indigoColor)
            }
            
            // Nickname
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
            sectionHeader("Account Info")
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "person.circle.fill",
                    title: "Nickname",
                    value: userNickname,
                    action: { isEditingNickname = true }
                )
                
                Divider()
                    .padding(.leading, 44)
                
                settingRow(
                    icon: "crown.fill",
                    title: "Subscription",
                    value: "Free Plan",
                    valueColor: .secondary
                )
                
                Divider()
                    .padding(.leading, 44)
            
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - App Info Section
    private var appSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("App Info")
            
            VStack(spacing: 0) {
                Button(action: {
                    // Force immediate update check with user interaction
                    if let updater = AppDelegate.shared.updaterController?.updater {
                        updater.checkForUpdates()
                    } else {
                        print("Error: Updater controller is nil")
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(indigoColor)
                            .frame(width: 24)
                        
                        Text("Check for Updates")
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
                    title: "Version",
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
            sectionHeader("Others")
            
            Button(action: { showingLogoutAlert = true }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Log Out")
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
    
    private func performLogout() {
        Task {
            await SupabaseAuthService().logout()
            try appLogLocalDataSource.removeAllAppLogs()
        }
        UserDefaults.standard.clearAllUserDefaults()
        KeychainHelper.standard.clearAll()
    }
}

#Preview {
    ProfileView()
}
