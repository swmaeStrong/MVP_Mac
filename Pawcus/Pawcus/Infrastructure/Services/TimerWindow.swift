//
//  TimerWindow.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import AppKit
import SwiftUI

class TimerWindow: NSWindow {
    private var timerManager: IndependentTimerManager
    private var hostingView: NSHostingView<TimerWindowView>?
    
    init(timerManager: IndependentTimerManager) {
        self.timerManager = timerManager
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 360),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupContent()
    }
    
    private func setupWindow() {
        title = "Focus Timer"
        isReleasedWhenClosed = false
        level = .floating
        
        // Make window transparent
        backgroundColor = NSColor.clear
        isOpaque = false
        hasShadow = true
        
        // Position window
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowSize = frame.size
            let x = screenRect.maxX - windowSize.width - 20
            let y = screenRect.maxY - windowSize.height - 20
            setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        // Make window appear above all others
        orderFrontRegardless()
    }
    
    private func setupContent() {
        let timerWindowView = TimerWindowView(
            timerManager: timerManager,
            onClose: { [weak self] in
                self?.close()
            }
        )
        
        hostingView = NSHostingView(rootView: timerWindowView)
        contentView = hostingView
    }
}

// Integrated Timer Window View that handles both selection and running states
struct TimerWindowView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
            
            if timerManager.isRunning || timerManager.isPaused {
                // Running timer view
                runningTimerView
            } else {
                // Timer selection view
                timerSelectionView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Timer Selection View
    private var timerSelectionView: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
                
                Text("Focus Timer")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Choose your focus method")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Timer mode selection
            VStack(spacing: 12) {
                // Stopwatch option
                HStack {
                    Image(systemName: "stopwatch")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stopwatch")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Count up from 0")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Start") {
                        timerManager.updateTimerMode(.stopwatch)
                        timerManager.start()
                    }
                    .buttonStyle(CompactButtonStyle(color: .green))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.1))
                )
                
                // Timer option
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Timer")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("Count down")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Start") {
                            timerManager.updateTimerMode(.timer)
                            timerManager.start()
                        }
                        .buttonStyle(CompactButtonStyle(color: .orange))
                    }
                    .padding(12)
                    
                    // Timer duration setting
                    HStack(spacing: 8) {
                        Button("-") {
                            let newDuration = max(5, timerManager.timerDurationMinutes - 5)
                            timerManager.updateTimerDuration(newDuration)
                        }
                        .buttonStyle(CompactCircleButtonStyle())
                        .disabled(timerManager.timerDurationMinutes <= 5)
                        
                        Text("\(timerManager.timerDurationMinutes) min")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .frame(minWidth: 60)
                        
                        Button("+") {
                            let newDuration = min(120, timerManager.timerDurationMinutes + 5)
                            timerManager.updateTimerDuration(newDuration)
                        }
                        .buttonStyle(CompactCircleButtonStyle())
                        .disabled(timerManager.timerDurationMinutes >= 120)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            // Close button
            Button("Close") {
                onClose()
            }
            .buttonStyle(CompactButtonStyle(color: .gray))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.9))
                .background(
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                )
                .shadow(radius: 10)
        )
    }
    
    // MARK: - Running Timer View
    private var runningTimerView: some View {
        VStack(spacing: 16) {
            // Timer display
            ZStack {
                if timerManager.isTimerMode {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: timerManager.progressPercentage)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: timerManager.progressPercentage)
                }
                
                Image(systemName: timerManager.timerMode.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 4) {
                Text(timerManager.displayTimeString)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Text(timerManager.timerMode == .timer ? "Timer" : "Stopwatch")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Control buttons
            HStack(spacing: 12) {
                Button(action: {
                    if timerManager.isPaused {
                        timerManager.start()
                    } else {
                        timerManager.pause()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 12))
                        Text(timerManager.isPaused ? "Resume" : "Pause")
                            .font(.system(size: 13))
                    }
                }
                .buttonStyle(CompactButtonStyle(color: .orange))
                
                Button(action: {
                    timerManager.stop()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 12))
                        Text("Stop")
                            .font(.system(size: 13))
                    }
                }
                .buttonStyle(CompactButtonStyle(color: .red))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.9))
                .background(
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                )
                .shadow(radius: 10)
        )
    }
}

// MARK: - Button Styles
struct CompactButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct CompactCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(Color.orange.opacity(configuration.isPressed ? 0.5 : 0.3))
            )
    }
}

// Visual effect for transparent blur background
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}