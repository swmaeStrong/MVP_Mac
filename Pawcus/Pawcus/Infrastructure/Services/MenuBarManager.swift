//
//  MenuBarManager.swift
//  Pawcus
//
//  Created by 김정원 on 6/19/25.
//

import AppKit
import SwiftUI
import Combine

final class MenuBarManager: ObservableObject {
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var independentTimer = IndependentTimerManager()
    private var cancellables = Set<AnyCancellable>()
    private var autoCloseTimer: Timer?
    
    // 타이머 설정 상태
    @Published var showTimerSelection = false
    
    init() {
        setupStatusItem()
        observeTimerState()
        updateMenuBarTime()
    }
    
    deinit {
        autoCloseTimer?.invalidate()
        cancellables.removeAll()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Focus Timer")
            button.image?.size = NSSize(width: 16, height: 16)
            button.image?.isTemplate = true
            button.action = #selector(statusItemClicked)
            button.target = self
            button.title = " 25:00"
            button.imagePosition = .imageLeading
        }
        
        statusItem?.isVisible = true
    }
    
    private func observeTimerState() {
        // 독립 타이머 실행 상태 관찰
        independentTimer.$isRunning
            .removeDuplicates()
            .sink { [weak self] isRunning in
                DispatchQueue.main.async {
                    self?.statusItem?.isVisible = true
                }
            }
            .store(in: &cancellables)
        
        // 독립 타이머 시간 변화 관찰
        independentTimer.$displayTimeString
            .removeDuplicates()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
        
        // 타이머 모드 변화 관찰
        independentTimer.$timerMode
            .removeDuplicates()
            .sink { [weak self] mode in
                DispatchQueue.main.async {
                    self?.updateMenuBarIcon(for: mode)
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
        
        // 타이머 지속시간 변화 관찰
        independentTimer.$timerDurationMinutes
            .removeDuplicates()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateMenuBarTime() {
        if let button = statusItem?.button {
            button.title = " \(independentTimer.displayTimeString)"
        }
    }
    
    private func updateMenuBarIcon(for mode: TimerMode) {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: mode.icon, accessibilityDescription: mode.displayName)
            button.image?.size = NSSize(width: 16, height: 16)
            button.image?.isTemplate = true
        }
    }
    
    @objc private func statusItemClicked() {
        togglePopover()
    }
    
    private func togglePopover() {
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
            autoCloseTimer?.invalidate()
            autoCloseTimer = nil
        } else {
            showPopover()
            autoCloseTimer?.invalidate()
            autoCloseTimer = nil
        }
    }
    
    private func showPopover() {
        setupPopover()
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        
        let menuBarView = IntegratedTimerPopoverView(timerManager: independentTimer)
        popover?.contentViewController = NSHostingController(rootView: menuBarView)
    }
    
    // 앱에서 타이머 설정 화면 표시
    func showTimerSelectionFromApp() {
        togglePopover()
    }
    
    // 타이머 시작 (앱과 메뉴바 공통)
    func startTimer() {
        independentTimer.start()
    }
    
    var timer: IndependentTimerManager {
        return independentTimer
    }
}

// 통합 타이머 팝오버 뷰 (선택 + 실행)
private struct IntegratedTimerPopoverView: View {
    @ObservedObject var timerManager: IndependentTimerManager
    
    var body: some View {
        VStack(spacing: 0) {
            if timerManager.isRunning || timerManager.isPaused {
                runningTimerView
            } else {
                timerSelectionView
            }
        }
        .background(Color(.windowBackgroundColor))
    }
    
    // MARK: - Timer Selection View
    private var timerSelectionView: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                Text("Focus Timer")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Choose your focus method")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Timer mode selection
            VStack(spacing: 12) {
                // Stopwatch option
                HStack {
                    Image(systemName: "stopwatch")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stopwatch")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text("Count up from 0")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Start") {
                        timerManager.updateTimerMode(.stopwatch)
                        timerManager.start()
                    }
                    .buttonStyle(CompactPopoverButtonStyle(color: .green))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
                
                // Timer option
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                            .frame(width: 25)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Timer")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Text("Count down")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Start") {
                            timerManager.updateTimerMode(.timer)
                            timerManager.start()
                        }
                        .buttonStyle(CompactPopoverButtonStyle(color: .orange))
                    }
                    .padding(10)
                    
                    // Timer duration setting
                    HStack(spacing: 8) {
                        Button("-") {
                            let newDuration = max(5, timerManager.timerDurationMinutes - 5)
                            timerManager.updateTimerDuration(newDuration)
                        }
                        .buttonStyle(CompactCirclePopoverButtonStyle())
                        .disabled(timerManager.timerDurationMinutes <= 5)
                        
                        Text("\(timerManager.timerDurationMinutes) min")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .frame(minWidth: 50)
                        
                        Button("+") {
                            let newDuration = min(120, timerManager.timerDurationMinutes + 5)
                            timerManager.updateTimerDuration(newDuration)
                        }
                        .buttonStyle(CompactCirclePopoverButtonStyle())
                        .disabled(timerManager.timerDurationMinutes >= 120)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding(16)
    }
    
    // MARK: - Running Timer View
    private var runningTimerView: some View {
        VStack(spacing: 24) {
            // Header Section
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: timerManager.timerMode.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text(timerManager.timerMode.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Text(timerManager.isPaused ? "Paused" : "Running")
                    .font(.system(size: 13))
                    .foregroundColor(timerManager.isPaused ? .orange : .green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((timerManager.isPaused ? Color.orange : Color.green).opacity(0.1))
                    )
            }
            
            // Timer Display Section
            VStack(spacing: 16) {
                if timerManager.isTimerMode {
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
                } else {
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
            
            // Control Buttons Section
            HStack(spacing: 12) {
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
            
            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Button Styles for Popover
struct CompactPopoverButtonStyle: ButtonStyle {
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

struct CompactCirclePopoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Color.orange.opacity(configuration.isPressed ? 0.5 : 0.3))
            )
    }
}