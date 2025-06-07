//
//  LoginService.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation
import Supabase
import SwiftUI

final class SupabaseAuthService {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    func loginWithGoogle() async -> Bool  {
        do {
            let session = try await supabase.auth.signInWithOAuth(
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
    
    func loginWithGithub() async -> Bool {
        do {
            let session = try await supabase.auth.signInWithOAuth(
                provider: .github,
                redirectTo: AppConfig.redirectToURL
            )
            print("Github login successful: \(session)")
            return true
        } catch {
            print("Github login failed: \(error)")
            return false
        }
    }
    
    func logout() async {
        do {
            try await supabase.auth.signOut()
            isLoggedIn = false
            print("Logout successful")
        } catch {
            print("Logout failed: \(error)")
        }
    }
}

struct ConsoleLogger: SupabaseLogger {
    func log(message: SupabaseLogMessage) {
        print(message)
    }
}
