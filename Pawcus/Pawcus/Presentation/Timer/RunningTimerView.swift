//
//  RunningTimerView.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import SwiftUI

struct RunningTimerView: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        VStack(spacing: 24) {
            Label(workTimeManager.mode.displayName, systemImage: workTimeManager.mode.icon)
                .font(.system(size: 18, weight: .bold))
                        
            TimerDisplayView()
            
            TimerControlsView()
            
        }
        .padding(20)
    }
}


// MARK: - Timer Display View
struct TimerDisplayView: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(workTimeManager.mode.color.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: workTimeManager.mode.icon)
                    .font(.system(size: 40))
                    .foregroundColor(workTimeManager.mode.color)
            }
            
            Text(workTimeManager.displayTimeString)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}



// MARK: - Timer Controls View
struct TimerControlsView: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        HStack(spacing: 12) {
            PauseResumeButton()
            StopButton()
        }
    }
}

// MARK: - Pause/Resume Button
struct PauseResumeButton: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        Button(action: {
            if workTimeManager.isPaused {
                workTimeManager.start()
            } else {
                workTimeManager.pause()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: workTimeManager.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 12))
                Text(workTimeManager.isPaused ? "Resume" : "Pause")
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
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        Button(action: {
            workTimeManager.stop()
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
    RunningTimerView()
        .environmentObject({
            let manager = WorkTimeManager()
            manager.start()
            return manager
        }())
        .frame(width: 320, height: 400)
}
