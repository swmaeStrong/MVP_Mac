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
    @State private var selectedCategory: String = UserRank2.Category.development.rawValue
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
    let userRanks: [UserRank2] = UserRank2.sampleData
    
    var body: some View {
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
                                        .fill(category == selectedCategory ? Color.black : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(category == selectedCategory ? .white : .primary)
                                .onTapGesture {
                                    selectedCategory = category
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                let filteredRanks = userRanks.filter { $0.category == selectedCategory }.sorted { $0.min > $1.min }
                let topRanks = filteredRanks.prefix(3)
                let otherRanks = filteredRanks.dropFirst(3)

                // Top 3 Horizontal
                HStack(spacing: 12) {
                    ForEach(Array(topRanks.enumerated()), id: \.element.id) { index, user in
                        VStack(spacing: 4) {
                            Text(index == 0 ? "🥇" : index == 1 ? "🥈" : "🥉")
                                .font(.largeTitle)
                            Text(user.username)
                                .bold()
                            Text(user.min.formattedDurationFromMinutes)
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
                    ForEach(Array(otherRanks.enumerated()), id: \.element.id) { index, user in
                        HStack {
                            Text("\(index + 4)") // Adjusted for index offset
                                .frame(width: 30, alignment: .leading)

                            Text(user.username)
                                .fontWeight(user.username == userNickname ? .bold : .regular)
                            Spacer()
                            Text(user.min.formattedDurationFromMinutes)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial))
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .onAppear {
            Task{
                await viewModel.loadUserRanks(date: Date())
            }
            print(userID)
            print(userNickname)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    userNickname = ""
                    userID = ""
                    print("새로고침 및 사용자 이름 초기화됨")
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .navigationTitle("LeaderBoard")
    }
}

#Preview {
    LeaderBoardView(viewModel: LeaderBoardViewModel())
}
