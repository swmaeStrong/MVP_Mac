//
//  LeaderBoardView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI

enum DateRangeType: String, CaseIterable, Identifiable {
    case today = "오늘"
    case week = "주간"
    case month = "월간"
    case custom = "날짜 선택"

    var id: String { rawValue }
}

struct LeaderBoardView: View {
    @ObservedObject var viewModel: LeaderBoardViewModel
    @State private var selectedRange: DateRangeType = .today
    @State private var isCalendarVisible: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("날짜 선택:")
                        .font(.headline)
                    Menu {
                        ForEach(DateRangeType.allCases) { type in
                            Button(type.rawValue) {
                                selectedRange = type
                                if type == .custom {
                                    isCalendarVisible = true
                                } else if type == .today {
                                    viewModel.selectedDate = Date()
                                }
                            }
                        }
                    } label: {
                        Label(viewModel.selectedDate.formattedDateString, systemImage: "calendar")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                    }

                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categoryNames, id: \.self) { category in
                                    Text(category)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .monospaced()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(category == viewModel.selectedCategory ? Color.black : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(category == viewModel.selectedCategory ? .white : .primary)
                                        .onTapGesture {
                                            viewModel.selectedCategory = category
                                            Task {
                                                await viewModel.loadUserTop10RanksByCategory()
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Top 3 Horizontal
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.top3RankUsers().enumerated()), id: \.offset) { index, user in
                                VStack(spacing: 4) {
                                    Text(index == 0 ? "🥇" : index == 1 ? "🥈" : "🥉")
                                        .font(.largeTitle)
                                    Text(user.nickname)
                                        .bold()
                                    Text("\(user.score)")
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Rest List
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.otherRankUsers().enumerated()), id: \.offset) { index, user in
                                HStack {
                                    Text("\(index + 4)")
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text(user.nickname)
                                    
                                    Spacer()
                                    Text("\(user.score)")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial))
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                    await viewModel.loadUserTop10RanksByCategory()
                }
            }
            
            .navigationTitle("LeaderBoard")
            // End VStack
            
            if isCalendarVisible {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea().onTapGesture {
                        isCalendarVisible = false
                    }
                    VStack {
                        CalendarOverlayView(selectedDate: $viewModel.selectedDate) {
                            isCalendarVisible = false
                        }
                    }
                }
                .transition(.opacity)
            }
        }
    }
}


#Preview {
    LeaderBoardView(viewModel: LeaderBoardViewModel())
}


struct CalendarOverlayView: View {
    @Binding var selectedDate: Date
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 4))
            .padding(.horizontal)
            Button("확인") {
                onDismiss()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.001)) // allows tap gesture passthrough
        .contentShape(Rectangle())
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
        .onTapGesture {
            onDismiss()
        }
    }
}
