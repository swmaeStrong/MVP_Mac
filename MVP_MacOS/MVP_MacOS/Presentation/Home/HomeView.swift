//
//  HomeView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI
import Combine
import SwiftData
import Factory

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    @Injected(\.appUsageLogger) private var appUsageLogger: AppUsageLogger
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Foucs Log")
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .bold()
            Text("💻 ..")
                .font(.title2)
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 250, height: 250)
                    .shadow(color: .gray.opacity(0.8), radius: 60, x: 0, y: 0)
                VStack {
                    Text(timeStore.formattedTime)
                        .font(.largeTitle)
                        .bold()
                        .monospaced()
                    Button(action: {
                        if timeStore.isRunning {
                            timeStore.stop()
                            appUsageLogger.stopLogging()
                        } else {
                            timeStore.start()
                            appUsageLogger.configure(context: modelContext)
                        }
                    }) {
                        Image(systemName: timeStore.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Home")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.black)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        await timeStore.sendLogs()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        await timeStore.deleteLogs()
                    }
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}


