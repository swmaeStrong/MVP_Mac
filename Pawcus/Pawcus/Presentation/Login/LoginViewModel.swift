//
//  LoginViewModel.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//


import Foundation
import Combine
import Supabase

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isGuest: Bool = false
    
    func loginWithGoogle() {
        let supabase = AppDelegate.shared.supabaseClient!
        Task {
            do {
                let session = try await supabase.auth.signInWithOAuth(provider: .google, redirectTo: URL(string: "pawcus://login-callback"))
                print("Google login successful: \(session)")
                isLoggedIn = true
            } catch {
                print("Google login failed: \(error)")
            }
        }
    }

    func continueAsGuest() {
        isGuest = true
        isLoggedIn = true
    }
}
