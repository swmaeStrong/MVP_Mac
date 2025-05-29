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
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
        
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
                                        .fill(category == viewModel.selectedCategory ? Color.black : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(category == viewModel.selectedCategory ? .white : .primary)
                                .onTapGesture {
                                    viewModel.selectedCategory = category
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
            .padding(.vertical)
        }
        .onAppear {
            Task {
                await viewModel.loadCategories()
                await viewModel.loadUserTop10Ranks()
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
