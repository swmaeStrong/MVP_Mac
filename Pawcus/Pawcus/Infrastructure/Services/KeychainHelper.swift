//
//  KeychainHelper.swift
//  Pawcus
//
//  Created by 김정원 on 6/5/25.
//

import Foundation
import Security

final class KeychainHelper {
    static let standard = KeychainHelper()

    private init() {}

    func save(_ data: String, service: String, account: String) {
        let data = Data(data.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete any existing item
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess else {
            return nil
        }

        guard let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
