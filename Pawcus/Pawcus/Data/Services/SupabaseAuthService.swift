//
//  LoginService.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation
import Supabase

final class SupabaseAuthService {
    
    let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseKey,
        options: .init(
            auth: .init(redirectToURL: AppConfig.redirectToURL),
            global: .init(logger: ConsoleLogger())
        )
    )
    
    func loginWithGoogle() async -> Bool {
        do {
            let session = try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: AppConfig.redirectToURL
            )
            print("Google login successful: \(session)")
            return true
        } catch {
            print("Google login failed: \(error)")
            return false
        }
    }
}

struct ConsoleLogger: SupabaseLogger {
    func log(message: SupabaseLogMessage) {
        print(message)
    }
}

