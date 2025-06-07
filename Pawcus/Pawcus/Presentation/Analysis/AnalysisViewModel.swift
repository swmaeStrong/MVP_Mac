//
//  AnalysisViewModel.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftUI
import Factory

final class AnalysisViewModel: ObservableObject {
    @ObservationIgnored
    @Injected(\.analyzeUsageUseCase) var analysisUseCase
    
    @Published var usageCategoryStat: [UsageCategoryStat] = []
    
    @MainActor
    func load() async {
        do {
           usageCategoryStat = try await analysisUseCase.fetchUsageCategoryStat(date: Date())
        } catch {
            print("ErrorAnalysysfetchUsageCategoryStat: \(error)")
        }
    }
}
