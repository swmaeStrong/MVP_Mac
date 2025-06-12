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
    @AppStorage(UserDefaultKey.userNickname.rawValue) private var nickname: String = ""
    @AppStorage(UserDefaultKey.isLoggedIn.rawValue) private var isLoggedIn: Bool = false
    @Injected(\.registerUserUseCase) private var registerUserUseCase
    private let supabaseAuthService: SupabaseAuthService = SupabaseAuthService()
    
    func loginWithGoogle() async {
        let success = await supabaseAuthService.loginWithGoogle()
        if success {
            do {
                let accessToken = try await supabase.auth.session.accessToken.description
                try await registerUserUseCase.registerSocialUser(accessToken: accessToken)
            } catch {
                // TODO: - 에러처리 
            }
        }
    }
    
    func loginWithGithub() async {
        let success = await supabaseAuthService.loginWithGithub()
        if success {
            do {
                let accessToken = try await supabase.auth.session.accessToken.description
                try await registerUserUseCase.registerSocialUser(accessToken: accessToken)
            } catch {
                
            }
        }
    }
    
    func continueAsGuest() async {
        do {
            try await registerUserUseCase.registerGuest()
        } catch {
            
        }
    }
}
