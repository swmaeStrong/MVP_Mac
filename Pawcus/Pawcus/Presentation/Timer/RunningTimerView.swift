//
//  RunningTimerView.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import SwiftUI

struct RunningTimerView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Header Section
            TimerHeaderView(timerManager: timerManager)
            
            // Timer Display Section
            TimerDisplayView(timerManager: timerManager)
            
            // Control Buttons Section
            TimerControlsView(timerManager: timerManager)
            
            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Timer Header View
struct TimerHeaderView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: timerManager.timerMode.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text(timerManager.timerMode.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            TimerStatusBadge(isPaused: timerManager.isPaused)
        }
    }
}

// MARK: - Timer Status Badge
struct TimerStatusBadge: View {
    let isPaused: Bool
    
    var body: some View {
        Text(isPaused ? "Paused" : "Running")
            .font(.system(size: 13))
            .foregroundColor(isPaused ? .orange : .green)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill((isPaused ? Color.orange : Color.green).opacity(0.1))
            )
    }
}

// MARK: - Timer Display View
struct TimerDisplayView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        VStack(spacing: 16) {
            if timerManager.isTimerMode {
                TimerProgressView(timerManager: timerManager)
            } else {
                StopwatchDisplayView(timerManager: timerManager)
            }
        }
    }
}

// MARK: - Timer Progress View (for countdown timer)
struct TimerProgressView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                .frame(width: 120, height: 120)
            
            Circle()
                .trim(from: 0, to: timerManager.progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timerManager.progressPercentage)
            
            VStack(spacing: 4) {
                Image(systemName: timerManager.timerMode.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text(timerManager.displayTimeString)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Stopwatch Display View
struct StopwatchDisplayView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: timerManager.timerMode.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            Text(timerManager.displayTimeString)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Timer Controls View
struct TimerControlsView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        HStack(spacing: 12) {
            PauseResumeButton(timerManager: timerManager)
            StopButton(timerManager: timerManager)
        }
    }
}

// MARK: - Pause/Resume Button
struct PauseResumeButton: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        Button(action: {
            if timerManager.isPaused {
                timerManager.start()
            } else {
                timerManager.pause()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 12))
                Text(timerManager.isPaused ? "Resume" : "Pause")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stop Button
struct StopButton: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        Button(action: {
            timerManager.stop()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 12))
                Text("Stop")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RunningTimerView(timerManager: {
        let manager = IndependentTimerManager()
        manager.start() // Start timer for preview
        return manager
    }())
    .frame(width: 320, height: 400)
}