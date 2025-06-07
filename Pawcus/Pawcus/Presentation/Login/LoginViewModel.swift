//
//  LoginViewModel.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//


import Foundation
import Combine
import Supabase

final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isGuest: Bool = false
    private let supabaseAuthService: SupabaseAuthService = SupabaseAuthService()
    
    func loginWithGoogle() async {
        isLoggedIn = await supabaseAuthService.loginWithGoogle()
    }
    
    func loginWithGithub() async {
        isLoggedIn = await supabaseAuthService.loginWithGithub()
    }
    
    func continueAsGuest() {
        isGuest = true
        isLoggedIn = true
    }
}
