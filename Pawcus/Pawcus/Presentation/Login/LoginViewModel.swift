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
import Factory

@MainActor
final class LoginViewModel: ObservableObject {
    @AppStorage("userNickname") private var nickname: String = ""
    @Published var showUsernamePrompt = false
    @Injected(\.registerUserUseCase) private var registerUserUseCase
    private let supabaseAuthService: SupabaseAuthService = SupabaseAuthService()
    
    func loginWithGoogle() async {
        let success = await supabaseAuthService.loginWithGoogle()
        if success {
            do {
                 let accessToken = try await supabase.auth.session.accessToken.description
                try await registerUserUseCase.registerSocialUser(accessToken: accessToken)
            } catch {
                
            }
           
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
