//
//  MenuBarPopoverView.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import SwiftUI

struct MenuBarPopoverView: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        VStack(spacing: 0) {
            if workTimeManager.isRunning || workTimeManager.isPaused {
                RunningTimerView()
            } else {
                TimerSelectionView()
            }
        }
        .frame(width: 240, height: 280)
        .background(Color(.windowBackgroundColor))
    }
}

// MARK: - Timer Selection View
struct TimerSelectionView: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 32))
                    .foregroundColor(.accent)
                
                Text("Pawcus")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Choose your focus method")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Timer mode selection
            VStack(spacing: 12) {
                // Stopwatch option
                TimerModeCard(
                    icon: "stopwatch",
                    title: "Stopwatch",
                    description: "Count up from 0",
                    color: .red,
                    action: {
                        workTimeManager.updateMode(.stopwatch)
                        workTimeManager.start()
                    }
                )
                
                // Timer option with duration controls
                TimerModeCard(
                    icon: "timer",
                    title: "Timer",
                    description: "Count down",
                    color: .indigo,
                    action: {
                        workTimeManager.updateMode(.timer)
                        workTimeManager.start()
                    },
                    additionalContent: {
                        TimerDurationControls()
                    }
                )
            }
        }
        .padding(16)
    }
}

// MARK: - Timer Mode Card
struct TimerModeCard<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    let additionalContent: (() -> Content)?
    
    init(
        icon: String,
        title: String,
        description: String,
        color: Color,
        action: @escaping () -> Void,
        @ViewBuilder additionalContent: @escaping () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
        self.action = action
        self.additionalContent = additionalContent
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 25)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Start") {
                    action()
                }
                .buttonStyle(TimerModeButtonStyle(color: color))
            }
            .padding(10)
            
            additionalContent?()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Timer Duration Controls
struct TimerDurationControls: View {
    @EnvironmentObject var workTimeManager: WorkTimeManager
    
    var body: some View {
        HStack(spacing: 8) {
            Button("-") {
                workTimeManager.decreaseTimerDuration()
            }
            .buttonStyle(TimerDurationButtonStyle())
            .disabled(workTimeManager.timerDurationMinutes <= 5)

            Text("\(workTimeManager.timerDurationMinutes) min")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .frame(minWidth: 50)

            Button("+") {
                workTimeManager.increaseTimerDuration()
            }
            .buttonStyle(TimerDurationButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}

// MARK: - Button Styles
struct TimerModeButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct TimerDurationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Color.indigo.opacity(configuration.isPressed ? 0.5 : 0.3))
            )
    }
}

#Preview {
    MenuBarPopoverView()
        .environmentObject(WorkTimeManager())
        .frame(width: 320, height: 400)
}
