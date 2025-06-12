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
    @StateObject private var viewModel = LoginViewModel()
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo and Welcome Section
            VStack(spacing: 24) {
                // App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(indigoColor.opacity(0.1))
                        .frame(width: 88, height: 88)
                    
                    Image(.pawcusIcon)
                        .font(.system(size: 44))
                        .foregroundColor(indigoColor)
                }
                
                // Welcome Text
                VStack(spacing: 8) {
                    Text("Welcome to Pawcus")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Track your productivity, compete with friends")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 48)
            .padding(.bottom, 40)
            
            // Sign In Options
            VStack(spacing: 12) {
                // Social Sign In Buttons
                VStack(spacing: 10) {
                    SocialSignInButton(
                        logoImageName: "GoogleLogo",
                        title: "Continue with Google",
                        backgroundColor: Color.white,
                        borderColor: Color(red: 0.85, green: 0.86, blue: 0.88)
                    ) {
                        Task { await viewModel.loginWithGoogle() }
                    }
                    
                    SocialSignInButton(
                        logoImageName: "GithubLogo",
                        title: "Continue with GitHub",
                        backgroundColor: Color(red: 36/255, green: 41/255, blue: 47/255),
                        textColor: Color.white,
                        borderColor: Color.clear,
                        invertLogo: true
                    ) {
                        Task { await viewModel.loginWithGithub() }
                    }
                }
                
                // Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, 8)
                
                // Guest Mode Button
                Button(action: {
                    Task { await viewModel.continueAsGuest() }
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 18))
                        
                        Text("Continue as Guest")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(indigoColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(indigoColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(indigoColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Footer
            VStack(spacing: 8) {
                Text("By continuing, you agree to our")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Button("Terms of Service") {
                        // Open terms
                    }
                    .buttonStyle(.link)
                    .font(.system(size: 11))
                    
                    Text("and")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Button("Privacy Policy") {
                        // Open privacy
                    }
                    .buttonStyle(.link)
                    .font(.system(size: 11))
                }
            }
            .padding(.bottom, 32)
        }
        .frame(width: 420, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SocialSignInButton: View {
    let logoImageName: String
    let title: String
    var backgroundColor: Color = Color.white
    var textColor: Color = Color(red: 0.24, green: 0.25, blue: 0.26)
    var borderColor: Color = Color(red: 0.85, green: 0.86, blue: 0.88)
    var invertLogo: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Spacer()
                Group {
                    if invertLogo {
                        Image(logoImageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(logoImageName)
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 20, height: 20)
                    }
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderColor == Color.clear ? 0 : 1)
            )
            .scaleEffect(isHovered ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
