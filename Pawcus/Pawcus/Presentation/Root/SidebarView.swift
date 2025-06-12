//
//  SidebarView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: Tab?
    @State private var hoveredTab: Tab? = nil
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Button Section
            
            SidebarTimerButton()
            
                .padding(.top, 24)
                .padding(.bottom, 24)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Navigation Items
            VStack(spacing: 4) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    if !tab.title.isEmpty {
                        SidebarButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            isHovered: hoveredTab == tab,
                            indigoColor: indigoColor,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }
                        )
                        .onHover { isHovered in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                hoveredTab = isHovered ? tab : nil
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom Section
            VStack(spacing: 12) {
                Divider()
                    .padding(.horizontal, 16)
                
                Text("Pawcus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("v1.0.0")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SidebarTimerButton: View {
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    @State private var isHovered = false
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                timeStore.isRunning ? timeStore.stop() : timeStore.start()
            }
        }) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: timeStore.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                
                // Text
                Text(timeStore.isRunning ? "Stop" : "Start")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        timeStore.isRunning ? 
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
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        timeStore.isRunning ? Color.red.opacity(0.3) : indigoColor.opacity(0.3),
                        lineWidth: timeStore.isRunning ? 2 : 0
                    )
                    .scaleEffect(timeStore.isRunning ? 1.1 : 1.0)
                    .opacity(timeStore.isRunning ? 0.7 : 0)
                    .animation(
                        timeStore.isRunning ? 
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : 
                        .default,
                        value: timeStore.isRunning
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SidebarButton: View {
    let tab: Tab
    let isSelected: Bool
    let isHovered: Bool
    let indigoColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? indigoColor.opacity(0.15) : 
                              (isHovered ? Color.gray.opacity(0.1) : Color.clear))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: tab.imageName)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? indigoColor : 
                                       (isHovered ? .primary : .secondary))
                }
                
                // Tab Title
                Text(tab.title)
                    .font(.system(size: 14, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(indigoColor)
                        .frame(width: 3, height: 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? indigoColor.opacity(0.08) : 
                          (isHovered ? Color.gray.opacity(0.05) : Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
}

// Tab Extension for titles
extension Tab {
    var title: String {
        switch self {
        case .analysis:
            return "Analytics"
        case .leaderboard:
            return "Leaderboard"
        case .profile:
            return "Profile"
        case .web:
            return "Web"
        }
    }
}
