//
//  SwiftDataAppLogRepository.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import Foundation
import SwiftData

/// SwiftData를 통한 로컬 영속화(읽기·쓰기·삭제)를 전담하는 매니저
final class AppLogRepository {
    
    /// AppLog 엔티티 저장
    func saveLog(_ log: AppLog, context: ModelContext) throws {
        let entity = AppLogEntity(from: log)
        context.insert(entity)
        print("저장 성공 \(log)")
    }
    
    /// 로컬에 저장된 모든 AppLogEntity 항목을 삭제
    func deleteAllLogs(context: ModelContext) throws {
        // 모든 엔티티 조회
        let allEntities = try context.fetch(FetchDescriptor<AppLogEntity>())
        // 각 엔티티 삭제
        for entity in allEntities {
            context.delete(entity)
        }
    }
    
}
