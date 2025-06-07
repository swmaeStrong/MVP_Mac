//
//  LoginViewModel.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//


import Foundation
import Combine
import Supabase
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @AppStorage("userNickname") private var nickname: String = ""
    @Published var showUsernamePrompt = false
    private let supabaseAuthService: SupabaseAuthService = SupabaseAuthService()
    
    func loginWithGoogle() async {
        let success = await supabaseAuthService.loginWithGoogle()
        if success {
            showUsernamePrompt = true
        }
    }
    
    func loginWithGithub() async {
        let success = await supabaseAuthService.loginWithGithub()
        if success {
            showUsernamePrompt = true
        }
    }
    
    func continueAsGuest() {
        showUsernamePrompt = true
    }
}
