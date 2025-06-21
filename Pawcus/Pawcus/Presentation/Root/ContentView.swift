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
    @EnvironmentObject private var workTimeManager: WorkTimeManager
    @EnvironmentObject private var menuBarManager: MenuBarManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selectedTab: $selectedTab)
            
            Divider()
                .ignoresSafeArea()
            
            // Main Content
            mainContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        case .profile:
            ProfileView()
        case .web:
            StatisticView()
        case .none:
            Text("Select a tab")
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(WorkTimeManager())
        .environmentObject(MenuBarManager())
}
