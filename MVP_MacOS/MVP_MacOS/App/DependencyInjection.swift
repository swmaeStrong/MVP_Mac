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
    }
}
