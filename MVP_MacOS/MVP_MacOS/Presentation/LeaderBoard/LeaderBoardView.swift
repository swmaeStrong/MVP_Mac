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
    @State private var selectedCategory: String = UserRank.Category.development.rawValue
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userID") private var userID: String = ""
    let userRanks: [UserRank] = UserRank.sampleData
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Picker("", selection: $selectedCategory) {
                    ForEach(viewModel.categoryNames, id: \.self) { category in
                        Text(category)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    let filteredRanks = userRanks.filter { $0.category == selectedCategory }.sorted{$0.min > $1.min}
                    ForEach(Array(filteredRanks.enumerated()), id: \.element.id) { index, user in
                        HStack {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 30, alignment: .leading)
                            Text(user.username)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(user.min.formattedDurationFromMinutes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .padding(.vertical)
        }
        .onAppear {
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
