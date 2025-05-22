//
//  LeaderBoardView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI

struct LeaderBoardView: View {
    @State private var selectedCategory: UserRank.Category = .development
    
    let userRanks: [UserRank] = UserRank.sampleData
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Picker("", selection: $selectedCategory) {
                    ForEach(UserRank.Category.allCases, id: \.self) { category in
                        Text(category.rawValue)
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
                            Text(user.min.formattedDuration)
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
        .navigationTitle("LeaderBoard")
    }
}

#Preview {
    LeaderBoardView()
}
