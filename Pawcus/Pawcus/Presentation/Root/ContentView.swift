//
//  ContentView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(UserDefaultKey.userNickname.rawValue) private var username: String = ""
    @State private var showUsernamePrompt: Bool = false
    @State private var selectedTab: Tab? = .leaderboard
    
    @StateObject private var leaderViewModel = LeaderBoardViewModel()
    @StateObject private var analysisViewModel = AnalysisViewModel()
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Sidebar
                SidebarView(selectedTab: $selectedTab)
                
                Divider()
                    .ignoresSafeArea()
                
                // Main Content
                mainContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .disabled(timeStore.isAppDisabled)
            .blur(radius: timeStore.isAppDisabled ? 3 : 0)
            
            // Timer Running Overlay
            if timeStore.isAppDisabled {
                timerRunningOverlay
            }
        }
        .onAppear {
            showUsernamePrompt = username.isEmpty
        }
        .sheet(isPresented: $showUsernamePrompt) {
            UserNamePromptView()
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .leaderboard:
            LeaderBoardView(viewModel: leaderViewModel)
        case .analysis:
            AnalysisView(viewModel: analysisViewModel)
        case .web:
            StatisticView()
        case .profile:
            ProfileView()
        case .none:
            Text("Select a tab")
        }
    }
    
    // MARK: - Timer Running Overlay
    private var timerRunningOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Timer info card
            VStack(spacing: 20) {
                // Timer icon with pulse animation
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(timeStore.isRunning ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: timeStore.isRunning)
                    
                    Image(systemName: "timer")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("Timer Running")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tracking your productivity...")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Timer display
                    Text(timeStore.seconds.formattedHMSFromSeconds)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
                
                // Stop button
                Button(action: {
                    withAnimation(.spring(response: 0.5)) {
                        timeStore.stop()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop Timer")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.red)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(1.0)
                .onHover { isHovered in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        // Can add hover effects here if needed
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

#Preview {
    ContentView()
        .environmentObject(DailyWorkTimeStore())
}
