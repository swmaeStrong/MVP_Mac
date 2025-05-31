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
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func loginWithGoogle() async {
        isLoggedIn = await authRepository.loginWithGoogle()
    }

    func continueAsGuest() {
        isGuest = true
        isLoggedIn = true
    }
}
