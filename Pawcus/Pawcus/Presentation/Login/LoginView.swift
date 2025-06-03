//
//  LoginView.swift
//  Pawcus
//
//  Created by 김정원 on 5/31/25.
//

import Foundation
import SwiftUI
import Factory
import Supabase

struct LoginView: View {
    @AppStorage("userNickname") private var userNickname = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showUsernamePrompt = false
    
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        if viewModel.isGuest || viewModel.isLoggedIn {
            UserNamePromptView(dd: $viewModel.isGuest)
        } else if !viewModel.isLoggedIn {
            VStack(spacing: 16) {
                Text("Welcome to Pawcus 🐾")
                    .font(.title2)
                
                // MARK: - Google Login
                SocialSignInButton(logoImageName: "GoogleLogo", title: "Sign in with Google", action: {
                    Task {
                        await viewModel.loginWithGoogle()
                    }
                })
                
                SocialSignInButton(logoImageName: "GithubLogo", title: "Sign in with Github", action: {
                    Task {
                        await viewModel.loginWithGithub()
                    }
                })
                Button("Guest Mode") {
                    viewModel.isGuest = true
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}

struct SocialSignInButton: View {
    let logoImageName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(logoImageName)
                    .resizable()
                    .frame(width: 18, height: 18)

                Text(title)
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

    }
}
