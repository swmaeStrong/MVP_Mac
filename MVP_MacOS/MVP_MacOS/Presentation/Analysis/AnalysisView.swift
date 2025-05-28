//
//  AnalysisView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI
import Charts
import SwiftData
import Factory

struct AnalysisView: View {
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    let data = CategoryUsageSummary.sampleData
    var body: some View {
        VStack(alignment: .leading){
            Text("Daily Summary")
                .font(.largeTitle)
                .bold()
                .monospaced()
                .padding()
            Text("Total Hours")
                .bold()
                .foregroundColor(.gray)
                .padding(.leading)
            Form {
                HStack {
                    Text(timeStore.seconds.formattedDurationFromSeconds)
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }
            }
            .background(.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.bottom)
            .padding(.horizontal)
            
            Text("Chart")
                .bold()
                .foregroundColor(.gray)
                .padding(.leading)
            Form {
                HStack{
                    Chart(data, id: \.category) {
                        SectorMark(
                            angle: .value("Duration", $0.duration),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle($0.color)
                    }
                    .frame(width: 200, height: 240)
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(data.sorted { $0.duration > $1.duration }, id: \.category) { entry in
                            HStack {
                                Circle()
                                    .fill(entry.color.opacity(0.8))
                                    .frame(width: 10, height: 10)
                                Text(entry.category)
                                    .font(.subheadline)
                                Spacer()
                                Text(entry.duration.formattedDurationFromMinutes)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .background(.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.bottom)
            .padding(.horizontal)
            Text("Top Categories")
                .bold()
                .foregroundColor(.gray)
                .padding(.leading)
            
        }
        .navigationTitle("Analysis")
    }
}

#Preview {
    AnalysisView()
}
