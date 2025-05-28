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
    var appLogLocalDataSource: Factory<AppLogLocalDataSource>{
        Factory(self) {
            AppLogLocalDataSource()
        }
        .singleton
    }
    
    var activityLogger: Factory<ActivityLogger> {
        Factory(self) {
            ActivityLogger(appLogLocalDataSource: AppLogLocalDataSource())
        }
        .singleton
    }
    
    var analysisService: Factory<AnalysisService> {
        Factory(self) {
            AnalysisService()
        }
        .singleton
    }
    
    
    var registerUserUseCase: Factory<RegisterUserUseCase> {
        Factory(self) {
            RegisterUserUseCase(repository: RegisterUserRepositoryImpl(service: UserRegisterService()))
        }
    }
    
    var syncUsageLogsUseCase: Factory<SyncUsageLogsUseCase> {
        Factory(self) {
            SyncUsageLogsUseCase(repository: AppLogRepositoryImpl(service: UsageLogService(), appLogLocalDataSource: AppLogLocalDataSource()))
        }
    }
    
    var fetchLeaderBoardUseCase: Factory<FetchLeaderBoardUseCase> {
        Factory(self) {
            FetchLeaderBoardUseCase(analysisRepository: AnalysisRepositoryImpl(service: AnalysisService()), leaderBoardRepository: LeaderBoardRepositoryImpl(service: UserRankService())
            )
        }
    }
    
    var analysisUseCase: Factory<AnalysisUseCase> {
        Factory(self) {
            AnalysisUseCase(analysisRepository: AnalysisRepositoryImpl(service: AnalysisService()))
        }
    }
}
