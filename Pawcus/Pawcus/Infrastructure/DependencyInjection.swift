//
//  DependencyInjection.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import Factory
import SwiftData

extension Container {
    
    var modelContext: Factory<ModelContext> {
        Factory(self) {
            let schema = Schema([AppLogEntity.self])
            let container = try! ModelContainer(for: schema)
            return ModelContext(container)
        }
        .singleton
    }
    
    // MARK: - 싱글톤 인스턴스
    var appLogLocalDataSource: Factory<AppLogLocalDataSource>{
        Factory(self) {
            AppLogLocalDataSource(context: self.modelContext())
        }
        .singleton
    }
    
    var activityLogger: Factory<ActivityLogger> {
        Factory(self) {
            ActivityLogger(appLogLocalDataSource: self.appLogLocalDataSource())
        }
        .singleton
    }
    
    var authService: Factory<SupabaseAuthService> {
        Factory(self) {
            SupabaseAuthService()
        }
        .singleton
    }
    
    var analysisService: Factory<UsageAnalysisService> {
        Factory(self) {
            UsageAnalysisService()
        }
        .singleton
    }
    
    // MARK: - UseCase
    var registerUserUseCase: Factory<RegisterUserUseCase> {
        Factory(self) {
            RegisterUserUseCase(repository: RegisterUserRepositoryImpl(service: UserRegisterService()))
        }
    }
    
    var transferUsageLogsUseCase: Factory<TransferUsageLogsUseCase> {
        Factory(self) {
            TransferUsageLogsUseCase(repository: AppLogRepositoryImpl(service: UsageLogService(), appLogLocalDataSource: self.appLogLocalDataSource()))
        }
    }
    
    var fetchLeaderBoardUseCase: Factory<FetchLeaderBoardUseCase> {
        Factory(self) {
            FetchLeaderBoardUseCase(analysisRepository: AnalysisRepositoryImpl(service: UsageAnalysisService()), leaderBoardRepository: LeaderBoardRepositoryImpl(service: UserRankService())
            )
        }
    }
    
    var analyzeUsageUseCase: Factory<AnalysisUseCase> {
        Factory(self) {
            AnalysisUseCase(analysisRepository: AnalysisRepositoryImpl(service: UsageAnalysisService()))
        }
    }
}
