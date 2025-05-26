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
    var swiftDataManager: Factory<SwiftDataManager> {
        Factory(self) {
            SwiftDataManager()
        }
        .singleton
    }

    var appUsageLogger: Factory<AppUsageLogger> {
        Factory(self) {
            AppUsageLogger()
        }
        .singleton
    }
    
    var dailyWorkTimeManager: Factory<DailyWorkTimeManager> {
        Factory(self) { DailyWorkTimeManager() }
            .singleton
    }
    
    var registerUserUseCase: Factory<RegisterUserUseCase> {
        Factory(self) {
            RegisterUserUseCase(service: UserRegisterService())
        }
    }
    
    var uploadUsageUseCase: Factory<UploadUsageLogUseCase> {
        Factory(self) {
            UploadUsageLogUseCase(service: UsageLogService())
        }
    }
}
