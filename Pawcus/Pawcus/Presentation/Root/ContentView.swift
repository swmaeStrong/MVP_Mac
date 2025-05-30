//
//  ContentView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    enum Tab: String, CaseIterable, Identifiable, Hashable {
        case home = "Home"
        case leaderboard = "LeaderBoard"
        case analysis = "Analysis"
        case profile = "Profile"
        var imageName : String {
            switch self {
            case .home: return "house.fill"
            case .leaderboard: return "chart.bar.fill"
            case .analysis: return "magnifyingglass.circle.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }
        var id: String { rawValue }
    }
    @StateObject var leaderViewModel: LeaderBoardViewModel = LeaderBoardViewModel()
    @StateObject var analysisViewModel: AnalysisViewModel = AnalysisViewModel()

    @State private var selection: Tab? = .home
    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selection) { tab in
                Label(tab.rawValue, systemImage: tab.imageName)
                .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationTitle("Tabs")
        } detail: {
            switch selection {
            case .home:
                HomeView()
            case .leaderboard:
                LeaderBoardView(viewModel: leaderViewModel)
            case .analysis:
                AnalysisView(viewModel: analysisViewModel)
            case .profile:
                ProfileView()
            case .none:
                Text("Select a tab")
            }
        }
        .frame(minWidth: 500, minHeight: 300)
        .background(.white)
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
        .environmentObject(DailyWorkTimeStore())
}
