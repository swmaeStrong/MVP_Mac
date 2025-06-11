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
    // MARK: - Properties
    @AppStorage("dailyWorkSeconds") private var storedSeconds: Int = 0
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    @Injected(\.activityLogger) private var appUsageLogger: ActivityLogger
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            headerView
            timerDisplay
            controlButtons
        }
        .navigationTitle("Home")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 400, minHeight: 200)
        .foregroundColor(.primary)
    }

    // MARK: - UI Components
    private var headerView: some View {
        Text("Timer")
            .monospaced()
            .bold()
            .font(.largeTitle)
    }

    private var timerDisplay: some View {
        Text("\(storedSeconds.formattedHMSFromSeconds)")
            .monospaced()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.7), value: timeStore.seconds.formattedHMSFromSeconds)
            .font(.system(size: 70, weight: .bold, design: .monospaced))
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            playPauseButton
            resetButton
        }
        .foregroundStyle(.secondary)
    }

    private var playPauseButton: some View {
        Button(action: toggleTimer) {
            Image(systemName: timeStore.isRunning ? "stop.fill" : "play.fill")
                .font(.title3)
                .padding()
                .background(
                    Capsule()
                        .fill(timeStore.isRunning ? Color.indigo.opacity(0.9) : Color.red.opacity(0.6))
                )
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }

    private var resetButton: some View {
        Button(action: resetTimer) {
            Image(systemName: "arrow.trianglehead.counterclockwise")
                .font(.title2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func toggleTimer() {
        if timeStore.isRunning {
            timeStore.stop()
            appUsageLogger.stopLogging()
        } else {
            timeStore.start()
            appUsageLogger.startLogging()
        }
    }

    private func resetTimer() {
        timeStore.reset()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [AppLogEntity.self], inMemory: true)
        .environmentObject(DailyWorkTimeStore())
}
