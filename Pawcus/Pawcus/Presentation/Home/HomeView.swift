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
import Sparkle

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    @Injected(\.activityLogger) private var appUsageLogger: ActivityLogger
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Timer")
                .monospaced()
                .bold()
                .font(.largeTitle)
            Text("\(timeStore.seconds.formattedHMSFromSeconds)")
                .monospaced()
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.7), value: timeStore.seconds.formattedHMSFromSeconds)
                .font(.system(size: 70, weight: .bold, design: .monospaced))
            
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
                                .fill(timeStore.isRunning ? Color.indigo.opacity(0.9): Color.red.opacity(0.6))
                        )
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                Button(action: {
                    
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
            }
            .foregroundStyle(.secondary)
        }
        .navigationTitle("Home")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 400, minHeight: 200)
        .foregroundColor(.primary)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [AppLogEntity.self], inMemory: true)
        .environmentObject(DailyWorkTimeStore())
    
}
