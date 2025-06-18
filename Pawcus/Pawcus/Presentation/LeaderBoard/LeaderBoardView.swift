//
//  LeaderBoardView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI

struct LeaderBoardView: View {
    @ObservedObject var viewModel: LeaderBoardViewModel
    @State private var isCalendarVisible: Bool = false
    @State private var hoveredRank: Int? = nil
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with date selector
                    headerSection
                    
                    // Category selector
                    categorySelector
                    
                    // Main content
                    if viewModel.userRankItems.isEmpty {
                        emptyStateView
                    } else {
                        // Top performer showcase
                        if let topUser = viewModel.top3RankUsers().first {
                            topPerformerCard(topUser)
                        }
                        
                        // Rankings grid
                        rankingsGrid
                    }
                }
                .padding(24)
            }
            .background(Color(.windowBackgroundColor))
            .navigationTitle("Leaderboard")
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                    await viewModel.loadUserTop10RanksByCategory()
                }
            }
            .onChange(of: viewModel.selectedDate) {
                Task {
                    await viewModel.loadUserTop10RanksByCategory()
                }
            }
            .onChange(of: viewModel.selectedRange) {
                Task {
                    await viewModel.loadUserTop10RanksByCategory()
                }
            }
            
            // Calendar overlay
            if isCalendarVisible {
                calendarOverlay
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Leaderboard")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Compete with other users and track your progress")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Date selector button
            dateSelectorButton
        }
    }
    
    // MARK: - Date Selector Button
    private var dateSelectorButton: some View {
        Menu {
            ForEach(DateRangeType.allCases) { type in
                Button(action: {
                    viewModel.selectedRange = type
                    Task {
                        await viewModel.loadUserTop10RanksByCategory()
                    }
                }) {
                    HStack {
                        Label(type.rawValue, systemImage: getDateRangeIcon(type))
                        if viewModel.selectedRange == type {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.caption)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.selectedRange.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(formatDateDisplay())
                        .font(.system(size: 14, weight: .medium))
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(indigoColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.primary)
        }
        .menuStyle(.borderlessButton)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categoryNames, id: \.self) { category in
                    CategoryPill(
                        title: category,
                        icon: AppCategoryType(from: category).iconName,
                        isSelected: category == viewModel.selectedCategory,
                        indigoColor: indigoColor
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedCategory = category
                        }
                        Task {
                            await viewModel.loadUserTop10RanksByCategory()
                        }
                    }
                }
            }
            .padding(.horizontal, 8) // 양쪽 여백 추가
        }
    }
    
    // MARK: - Top Performer Card
    private func topPerformerCard(_ user: UserRankItem) -> some View {
        VStack(spacing: 0) {
            // Crown header
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 255/255, green: 215/255, blue: 0/255),
                        Color(red: 255/255, green: 184/255, blue: 0/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("👑 \(getChampionTitle())")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        Text("in \(viewModel.selectedCategory)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text(String(format: "%.1f", user.score))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            
            // User info
            HStack(spacing: 16) {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [indigoColor, indigoColor.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(user.nickname.prefix(2).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.nickname)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Achieved top position")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color(.controlBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 5)
    }
    
    // MARK: - Rankings Grid
    private var rankingsGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Rankings")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Text("\(viewModel.userRankItems[viewModel.selectedCategory]?.count ?? 0) participants")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(Array(viewModel.userRankItems[viewModel.selectedCategory]?.enumerated() ?? [].enumerated()), id: \.offset) { index, user in
                    RankingCard(
                        user: user,
                        rank: index + 1,
                        indigoColor: indigoColor,
                        isHovered: hoveredRank == index + 1
                    )
                    .onHover { isHovered in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hoveredRank = isHovered ? index + 1 : nil
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [indigoColor, indigoColor.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No rankings yet")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Be the first to set a record in \(viewModel.selectedCategory)!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Refresh action
                Task {
                    await viewModel.loadUserTop10RanksByCategory()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(indigoColor)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Calendar Overlay
    private var calendarOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        isCalendarVisible = false
                    }
                }
            
            VStack(spacing: 20) {
                HStack {
                    Text("Select Date")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isCalendarVisible = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accentColor(indigoColor)
                
                HStack(spacing: 12) {
                    Button("Today") {
                        viewModel.selectedDate = Date()
                        withAnimation(.spring(response: 0.3)) {
                            isCalendarVisible = false
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Done") {
                        withAnimation(.spring(response: 0.3)) {
                            isCalendarVisible = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(indigoColor)
                }
            }
            .padding(24)
            .background(Color(.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 30)
            .frame(width: 350)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private func formatDateDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private func getDateRangeIcon(_ type: DateRangeType) -> String {
        switch type {
        case .today:
            return "sun.max.fill"
        case .week:
            return "calendar.day.timeline.left"
        case .month:
            return "calendar.month.grid"
        case .custom:
            return "calendar.badge.plus"
        }
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "development":
            return "chevron.left.forwardslash.chevron.right"
        case "productivity":
            return "chart.line.uptrend.xyaxis"
        case "communication":
            return "bubble.left.and.bubble.right"
        case "entertainment":
            return "tv"
        case "education":
            return "book"
        case "design":
            return "paintbrush"
        case "social":
            return "person.2"
        default:
            return "app"
        }
    }
    
    private func getChampionTitle() -> String {
        switch viewModel.selectedRange {
        case .today:
            return "Today's Champion"
        case .week:
            return "This Week's Champion"
        case .month:
            return "This Month's Champion"
        case .custom:
            return "Champion on Selected Date"
        }
    }
}

// MARK: - Supporting Views

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let indigoColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        LinearGradient(
                            gradient: Gradient(colors: [indigoColor, indigoColor.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(.controlBackgroundColor)
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0) // 스케일링을 줄임 (1.05 -> 1.02)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct RankingCard: View {
    let user: UserRankItem
    let rank: Int
    let indigoColor: Color
    let isHovered: Bool
    
    private var rankDisplay: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 255/255, green: 215/255, blue: 0/255)
        case 2: return Color(red: 192/255, green: 192/255, blue: 192/255)
        case 3: return Color(red: 205/255, green: 127/255, blue: 50/255)
        default: return indigoColor
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Group {
                if rank <= 3 {
                    Text(rankDisplay)
                        .font(.system(size: 28))
                        .frame(width: 50)
                } else {
                    Text(rankDisplay)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(rankColor)
                        .frame(width: 50)
                }
            }
            
            // User avatar and info
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                rankColor.opacity(0.3),
                                rankColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(user.nickname.prefix(2).uppercased())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(rankColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.nickname)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    if rank <= 3 {
                        Text(getRankTitle(rank))
                            .font(.system(size: 12))
                            .foregroundColor(rankColor)
                    }
                }
            }
            
            Spacer()
            
            // Score with animation
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", user.score))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(rank <= 3 ? rankColor : .primary)
                Text("points")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                if rank <= 3 {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            rankColor.opacity(0.1),
                            rankColor.opacity(0.05)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color(.controlBackgroundColor)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    rank <= 3 ? rankColor.opacity(0.3) : Color.gray.opacity(0.1),
                    lineWidth: rank <= 3 ? 2 : 1
                )
        )
        .shadow(
            color: isHovered ? rankColor.opacity(0.2) : Color.black.opacity(0.05),
            radius: isHovered ? 15 : 5,
            x: 0,
            y: isHovered ? 5 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
    }
    
    private func getRankTitle(_ rank: Int) -> String {
        switch rank {
        case 1: return "Champion"
        case 2: return "Runner-up"
        case 3: return "3rd Place"
        default: return ""
        }
    }
}

#Preview {
    LeaderBoardView(viewModel: LeaderBoardViewModel())
        .frame(width: 900, height: 700)
}
