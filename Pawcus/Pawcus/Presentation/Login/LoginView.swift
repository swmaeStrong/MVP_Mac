//
//  LoginView.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//

import Foundation
import SwiftUI
import Factory

struct LoginView: View {
    @State private var showUsernamePrompt = false
    @StateObject private var viewModel = LoginViewModel(authRepository: LoginService())

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Pawcus 🐾")
                .font(.title2)
            
            // MARK: - Google Login
            Button(action: {
                Task {
                    await viewModel.loginWithGoogle()
                }
            }) {
                HStack(spacing: 8) {
                    Image("GoogleLogo")
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Text("Sign in with Google")
                        .fontWeight(.medium)
                        .font(Font.custom("Roboto", size: 14))
                        .kerning(0.25)
                        .foregroundColor(Color(red: 0.24, green: 0.25, blue: 0.26))
                }
                .frame(width: 346, height: 40)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.85, green: 0.86, blue: 0.88), lineWidth: 1)
                )
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            Button("Guest Mode") {
                showUsernamePrompt = true
            }
        }
        .padding()
        .frame(width: 300)
        .sheet(isPresented: $showUsernamePrompt) {
            GuestModePromptView()
        }
    }
}


