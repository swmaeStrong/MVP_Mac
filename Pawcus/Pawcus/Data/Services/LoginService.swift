//
//  LoginService.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation
import Supabase

@MainActor
final class LoginService: AuthRepository {
    let supabase = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseKey
    )

    func loginWithGoogle() async -> Bool {
        do {
            let session = try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "pawcus://login-callback")
            )
            print("Google login successful: \(session)")
            return true
        } catch {
            print("Google login failed: \(error)")
            return false
        }
    }
}
