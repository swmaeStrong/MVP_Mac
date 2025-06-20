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
    @EnvironmentObject private var workTimeManager: WorkTimeManager
    @ObservedObject var viewModel: AnalysisViewModel
    
    // Indigo theme color
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Total Time Card
                totalTimeCard
                
                // Category Chart Card
                categoryChartCard
                
                // Category List
                categoryListCard
            }
            .padding(24)
        }
        .background(Color(.windowBackgroundColor))
        .navigationTitle("Analysis")
        .onAppear {
            Task {
                await viewModel.load()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Summary")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Track your productivity and app usage")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Total Time Card
    private var totalTimeCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Hours Today")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.totalTime.formattedDurationFromSeconds)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(indigoColor)
                }
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(indigoColor.opacity(0.2))
            }
            .padding(24)
        }
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Category Chart Card
    private var categoryChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Distribution")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            if viewModel.usageCategoryStat.isEmpty {
                emptyChartView
            } else {
                HStack(spacing: 32) {
                    // Pie Chart
                    Chart(viewModel.usageCategoryStat) { category in
                        SectorMark(
                            angle: .value("Duration", category.duration),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(Color(hex: category.color) ?? indigoColor)
                        .cornerRadius(4)
                    }
                    .frame(width: 200, height: 200)
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            let frame = geometry.frame(in: .local)
                            VStack {
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.usageCategoryStat.reduce(0) { $0 + $1.duration }.formattedHMSFromSeconds)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.usageCategoryStat.sorted { $0.duration > $1.duration }.prefix(5)) { category in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: category.color) ?? indigoColor)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.category)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(category.duration.formattedHMSFromSeconds)
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(24)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Category List Card
    private var categoryListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("All Categories")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.usageCategoryStat.count) categories")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            if viewModel.usageCategoryStat.isEmpty {
                Text("No data available yet. Start tracking your time!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.usageCategoryStat.sorted { $0.duration > $1.duration }) { category in
                        categoryRow(category)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Category Row
    private func categoryRow(_ category: UsageCategoryStat) -> some View {
        HStack(spacing: 16) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: category.color) ?? indigoColor)
                .frame(width: 4, height: 40)
            
            // Category icon
            Image(systemName: AppCategoryType(from: category.category).iconName)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: category.color) ?? indigoColor)
                .frame(width: 32)
            
            // Category name
            Text(category.category)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: category.color) ?? indigoColor)
                        .frame(
                            width: max(0, min(geometry.size.width, geometry.size.width * (Double(category.duration) / Double(maxDuration)))),
                            height: 8
                        )
                }
            }
            .frame(width: 100, height: 8)
            
            // Duration
            Text(category.duration.formattedHMSFromSeconds)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Empty Chart View
    private var emptyChartView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No activity data yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    // MARK: - Helper Properties
    private var maxDuration: Int {
        let max = viewModel.usageCategoryStat.map { Int($0.duration) }.max() ?? 0
        return max > 0 ? max : 1
    }
    
//    // MARK: - Helper Functions
//    private func getCategoryIcon(_ category: String) -> String {
//        switch category.lowercased() {
//        case "productivity":
//            return "chart.line.uptrend.xyaxis"
//        case "development":
//            return "chevron.left.forwardslash.chevron.right"
//        case "communication":
//            return "message.fill"
//        case "entertainment":
//            return "tv.fill"
//        case "social":
//            return "person.2.fill"
//        case "utilities":
//            return "wrench.and.screwdriver.fill"
//        case "education":
//            return "book.fill"
//        case "design":
//            return "paintbrush.fill"
//        default:
//            return "app.fill"
//        }
//    }
}

#Preview {
    AnalysisView(viewModel: AnalysisViewModel())
        .environmentObject(WorkTimeManager())
        .frame(width: 800, height: 600)
}
