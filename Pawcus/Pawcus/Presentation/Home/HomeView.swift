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
    @Injected(\.activityLogger) private var appUsageLogger: ActivityLogger
    
    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            VStack(spacing: 20) {
                Text("\(timeStore.seconds.formattedHMSFromSeconds)")
                    .monospaced()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.7), value: timeStore.seconds.formattedHMSFromSeconds)
                    .font(.system(size: 70, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                HStack(spacing: 10){
                    
                    Button(action: {
                        if timeStore.isRunning {
                            timeStore.stop()
                            appUsageLogger.stopLogging()
                        } else {
                            timeStore.start()
                            appUsageLogger.configure(context: modelContext)
                        }
                    }) {
                        Image(systemName: timeStore.isRunning ? "stop.fill" : "play.fill")
                            .font(.title3)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(timeStore.isRunning ? Color.indigo.opacity(0.9): Color.red.opacity(0.4))
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        
                    }) {
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                
                }
            }
        }
        .navigationTitle("Home")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 400, minHeight: 100)
        .foregroundColor(.primary)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.indigo.opacity(0.7)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        await timeStore.sendLogs()
                    }
                } label: {
                    Label("Send Logs", systemImage: "paperplane.fill")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        await timeStore.deleteLogs()
                    }
                } label: {
                    Label("Delete Logs", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [AppLogEntity.self], inMemory: true)
        .environmentObject(DailyWorkTimeStore())

}

struct TimerCard: View {
    let value: Int
    //let label: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Text(String(value))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .id(value)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.8), value: value)
            }
        }
        .padding()
        .frame(width: 100, height: 100)
    }
}
