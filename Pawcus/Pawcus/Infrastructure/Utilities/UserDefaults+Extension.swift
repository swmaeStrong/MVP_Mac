//
//  UserDefaults+Extension.swift
//  Pawcus
//
//  Created by 김정원 on 6/10/25.
//

import Foundation

/// UserDefaults에 저장할 키를 모아두는 enum
enum UserDefaultKey: String {
    case userNickname
    case userId
    case isLoggedIn
    case dailyWorkSeconds
    case lastRecordedDate
    case createdAt
}

extension UserDefaults {
    
    /// 값 저장하기
    func set<T>(_ value: T, forKey key: UserDefaultKey) {
        set(value, forKey: key.rawValue)
    }
    
    /// 값 읽어오기 (타입 안전)
    func value<T>(forKey key: UserDefaultKey) -> T? {
        return object(forKey: key.rawValue) as? T
    }
    
    /// Bool 읽기 전용 편의 메서드
    func bool(forKey key: UserDefaultKey) -> Bool {
        return bool(forKey: key.rawValue)
    }
    
    /// Int 읽기 전용 편의 메서드
    func integer(forKey key: UserDefaultKey) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    /// 문자열 읽기 전용 편의 메서드
    func string(forKey key: UserDefaultKey) -> String? {
        return string(forKey: key.rawValue)
    }
    
    /// 값 삭제하기
    func remove(_ key: UserDefaultKey) {
        removeObject(forKey: key.rawValue)
    }
}
