//
//  ContentView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userNickname") private var username: String = ""
    @State private var showUsernamePrompt: Bool = false
    @State private var selectedTab: Tab? = .leaderboard
    
    @StateObject private var leaderViewModel = LeaderBoardViewModel()
    @StateObject private var analysisViewModel = AnalysisViewModel()
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack {
                SidebarView(selectedTab: $selectedTab)
                TimerButton()
            }
            
            Divider()
                .ignoresSafeArea()
        
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
        case .web:
            StatisticView()
        case .profile:
            ProfileView()
        case .none:
            Text("Select a tab")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DailyWorkTimeStore())
}
