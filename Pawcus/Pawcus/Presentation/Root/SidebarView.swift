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
                
                Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
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
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @State private var isHovered = false
    
    // 밝고 예쁜 색상들
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)

    var body: some View {
        Button(action: {
            // 단순히 메뉴바 팝오버만 열기
            menuBarManager.showTimerSelectionFromApp()
        }) {
            VStack(spacing: 8) {
                // Icon - 고정된 타이머 아이콘
                Image(systemName: "timer")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(isHovered ? 1.15 : 1.0)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                // Text
                Text("Focus Timer")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0.5)
            }
            .frame(width: 130, height: 85)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [indigoColor, Color.blue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: indigoColor.opacity(0.4), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
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
