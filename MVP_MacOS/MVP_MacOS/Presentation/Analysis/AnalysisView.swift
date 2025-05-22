//
//  AnalysisView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI
import SwiftData

struct AnalysisView: View {
    @Query private var logs: [AppLogEntity]
    var body: some View {
        List(logs) { log in
            VStack(alignment: .leading, spacing: 4) {
                Text(log.app)
                    .font(.headline)
                Text(log.title)
                    .font(.subheadline)
                Text(log.duration.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("로그 분석")
    }
}
