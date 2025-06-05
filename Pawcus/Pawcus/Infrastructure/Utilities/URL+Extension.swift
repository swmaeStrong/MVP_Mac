//
//  URL+Extension.swift
//  Pawcus
//
//  Created by 김정원 on 6/5/25.
//

import Foundation

extension URLRequest {
    mutating func addJSONHeader() {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    mutating func addBearerTokenIfAvailable() {
        if let token = KeychainHelper.standard.read(service: "com.pawcus.token", account: "accessToken") {
            self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
