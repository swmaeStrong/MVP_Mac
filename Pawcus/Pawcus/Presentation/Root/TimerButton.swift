//
//  TimerButton.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct TimerButton: View {
    @EnvironmentObject private var workTimeManager: WorkTimeManager
    
    var body: some View {
        Image(systemName: workTimeManager.isRunning ? "stop.fill" : "play.fill")
            .font(.largeTitle)
            .frame(width: 70, height: 50)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [workTimeManager.isRunning ? .red : .indigo, workTimeManager.isRunning ? .pink.opacity(0.5) : .blue.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                workTimeManager.isRunning ? workTimeManager.stop() : workTimeManager.start()
            }
            .padding()
    }
}

struct FloatingTimerButton: View {
    @EnvironmentObject private var workTimeManager: WorkTimeManager
    @State private var isHovered = false
    @State private var isPulsing = false
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        ZStack {
            // Shadow layer
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black.opacity(0.1))
                .frame(width: buttonWidth + 4, height: 68)
                .offset(x: 0, y: 2)
                .blur(radius: 4)
            
            // Main button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    workTimeManager.isRunning ? workTimeManager.stop() : workTimeManager.start()
                }
            }) {
                HStack(spacing: 8) {
                    // Icon
                    Image(systemName: workTimeManager.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                    
                    // Text
                    Text(workTimeManager.isRunning ? "Stop" : "Start")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            workTimeManager.isRunning ? 
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [indigoColor, indigoColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // Pulse animation for running state
            if workTimeManager.isRunning {
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    .frame(width: isPulsing ? buttonWidth + 16 : buttonWidth, height: isPulsing ? 80 : 64)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isPulsing
                    )
                    .onAppear {
                        isPulsing = true
                    }
                    .onDisappear {
                        isPulsing = false
                    }
            }
        }
        .onChange(of: workTimeManager.isRunning) { _, newValue in
            if newValue {
                isPulsing = true
            } else {
                isPulsing = false
            }
        }
    }
    
    private var buttonWidth: CGFloat {
        workTimeManager.isRunning ? 88 : 96 // "Stop" vs "Start"
    }
}