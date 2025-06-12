//
//  ContentView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userNickname") private var username: String = ""
    @AppStorage(UserDefaultKey.dailyWorkSeconds.rawValue) private var storedTime: Int = 0

    @State private var showUsernamePrompt: Bool = false
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    
    enum Tab: String, CaseIterable, Identifiable, Hashable {
        case leaderboard = "LeaderBoard"
        case analysis = "Analysis"
        case profile = "Profile"
        case web = "web"
        var imageName : String {
            switch self {
            case .leaderboard: return "chart.bar.fill"
            case .analysis: return "magnifyingglass.circle.fill"
            case .profile: return "person.crop.circle.fill"
            case .web: return "plus.circle.fill"
            }
        }
        var id: String { rawValue }
    }
    
    @StateObject var leaderViewModel: LeaderBoardViewModel = LeaderBoardViewModel()
    @StateObject var analysisViewModel: AnalysisViewModel = AnalysisViewModel()
    
    @State private var selection: Tab? = .leaderboard
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            VStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        selection = tab
                    }) {
                        Image(systemName:  tab.imageName)
                            .foregroundStyle(selection == tab ? .accent : .secondary)
                            .font(.title)
                            .padding(.vertical)
                            .frame(width: 70, height: 50)

                    }
                    .buttonStyle(.plain)
                }
                .padding(.top,5)
                Divider()
                    .padding()
                Spacer()
                Image(systemName: timeStore.isRunning ? "stop.fill" : "play.fill")
                    .font(.largeTitle)
                    .frame(width: 70, height: 50)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [timeStore.isRunning ? .red : .indigo, timeStore.isRunning ? .pink.opacity(0.5) : .blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        timeStore.isRunning ? timeStore.stop() : timeStore.start()
                    }
                    .padding()
            }
            .frame(width: 100)
            .background(Color(.windowBackgroundColor))
            
            Divider()
                .ignoresSafeArea()
            
            Group {
                switch selection {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            showUsernamePrompt = username.isEmpty
        }
        .sheet(isPresented: $showUsernamePrompt) {
            UserNamePromptView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DailyWorkTimeStore())
}
