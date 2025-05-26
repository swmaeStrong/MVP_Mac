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

        var id: String { rawValue }
    }

    @State private var selection: Tab? = .home
    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selection) { tab in
                Text(tab.rawValue)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationTitle("Tabs")
        } detail: {
            switch selection {
            case .home:
                HomeView()
            case .leaderboard:
                LeaderBoardView()
            case .analysis:
                AnalysisView()
            case .none:
                Text("Select a tab")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
}
