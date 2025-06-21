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
    private var cancellables = Set<AnyCancellable>()
    private var autoCloseTimer: Timer?
    
    // WorkTimeManager를 직접 참조
    weak var workTimeManager: WorkTimeManager? {
        didSet {
            if workTimeManager != nil {
                Task { @MainActor in
                    observeTimerState()
                    updateMenuBarTime()
                }
            }
        }
    }
    
    // 타이머 설정 상태
    @Published var showTimerSelection = false
    
    init() {
        Task {
            await setupStatusItem()
        }
    }
    
    deinit {
        autoCloseTimer?.invalidate()
        cancellables.removeAll()
    }
    
    @MainActor
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 80)

        if let button = statusItem?.button {
            // 초기 빨간색 원 설정
            let circleImage = NSImage(size: NSSize(width: 12, height: 12))
            circleImage.lockFocus()
            NSColor.systemRed.setFill()
            let path = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 10, height: 10))
            path.fill()
            circleImage.unlockFocus()
            
            button.image = circleImage
            button.image?.isTemplate = false
            button.action = #selector(statusItemClicked)
            button.target = self
            button.imagePosition = .imageLeading

            // ✅ 자간 조절된 텍스트 설정
            let title = " 25:00"
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [
                    .kern: 2.0,
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize)
                ]
            )
            button.attributedTitle = attributedTitle
        }

        statusItem?.isVisible = true
    }
    @MainActor
    private func observeTimerState() {
        guard let workTimeManager = workTimeManager else { return }
        
        // 워크타임 매니저 실행 상태 관찰
        workTimeManager.$isRunning
            .removeDuplicates()
            .sink { [weak self] isRunning in
                DispatchQueue.main.async {
                    self?.statusItem?.isVisible = true
                    self?.updateCircleColor(isRunning: isRunning)
                }
            }
            .store(in: &cancellables)
        
        // 워크타임 매니저 시간 변화 관찰
        workTimeManager.$displayTimeString
            .removeDuplicates()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
        
        // 워크타임 매니저 모드 변화 관찰
        workTimeManager.$mode
            .removeDuplicates()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
        
        // 타이머 지속시간 변화 관찰
        workTimeManager.$timerDurationMinutes
            .removeDuplicates()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarTime()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func updateMenuBarTime() {
        guard let workTimeManager = workTimeManager else { return }
        if let button = statusItem?.button {
            button.title = " \(workTimeManager.displayTimeString)"
        }
    }
    
    private func updateCircleColor(isRunning: Bool) {
        if let button = statusItem?.button {
            // 녹색 원 또는 빨간색 원 생성
            let circleImage = NSImage(size: NSSize(width: 10, height: 10))
            circleImage.lockFocus()
            
            let color = isRunning ? NSColor.systemGreen : NSColor.systemRed
            color.setFill()
            
            let path = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 10, height: 10))
            path.fill()
            
            circleImage.unlockFocus()
            
            button.image = circleImage
            button.image?.isTemplate = false
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
        guard let workTimeManager = workTimeManager else { return }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        
        let menuBarView = MenuBarPopoverView()
            .environmentObject(workTimeManager)
        popover?.contentViewController = NSHostingController(rootView: menuBarView)
    }
    
    // 앱에서 타이머 설정 화면 표시
    func showTimerSelectionFromApp() {
        togglePopover()
    }
    
    // 타이머 시작 (앱과 메뉴바 공통)
    func startTimer() {
        Task { @MainActor in
            workTimeManager?.start()
        }
    }
}

