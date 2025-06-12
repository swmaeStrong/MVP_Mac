//
//  UserNamePromptView.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation
import SwiftUI
import Factory

struct UserNamePromptView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = UserNamePromptViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    private let indigoColor = Color(red: 88/255, green: 86/255, blue: 214/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(indigoColor)
                    .padding(.top, 32)
                
                Text("Choose Your Nickname")
                    .font(.system(size: 24, weight: .semibold))
                
                Text("This is how other users will see you")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
            
            // Input Section
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        ZStack(alignment: .trailing) {
                            TextField("Enter nickname", text: $vm.tempInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            vm.isChecking ? indigoColor.opacity(0.5) :
                                            (vm.isValidNickname == true ? Color.green :
                                            (vm.isValidNickname == false ? Color.red : Color.clear)),
                                            lineWidth: vm.isValidNickname != nil || vm.isChecking ? 2 : 0
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .focused($isTextFieldFocused)
                                .onChange(of: vm.tempInput) {
                                    vm.isValidNickname = nil
                                    vm.statusMessage = nil
                                }
                                .onSubmit {
                                    if !vm.tempInput.isEmpty {
                                        Task { await vm.validate() }
                                    }
                                }
                            
                            // Status Icon
                            if vm.isChecking {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .padding(.trailing, 16)
                            } else if let image = vm.nicknameStatusImage {
                                Image(systemName: image)
                                    .foregroundColor(vm.nicknameStatusColor)
                                    .padding(.trailing, 16)
                            }
                        }
                        
                        Button(action: {
                            Task { await vm.validate() }
                        }) {
                            Text("Check")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    vm.tempInput.isEmpty || vm.isChecking ? 
                                    Color.gray.opacity(0.5) : indigoColor
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .disabled(vm.tempInput.trimmingCharacters(in: .whitespaces).isEmpty || vm.isChecking)
                    }
                    
                    // Status Message
                    if let message = vm.statusMessage {
                        HStack(spacing: 4) {
                            Text(message)
                                .font(.system(size: 12))
                                .foregroundColor(vm.nicknameStatusColor)
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                    }
                }
                
                // Guidelines
                VStack(alignment: .leading, spacing: 8) {
                    Label("3-20 characters", systemImage: "character.textbox")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Label("Letters, numbers, and underscores only", systemImage: "textformat.abc.dottedunderline")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Bottom Actions
            HStack(spacing: 12) {
                if vm.showCancelButton() {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    Task {
                        await vm.confirm()
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            vm.isValidNickname == true ? indigoColor : Color.gray.opacity(0.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!(vm.isValidNickname ?? false))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
        .onReceive(vm.$didConfirm) { didConfirm in
            if didConfirm {
                dismiss()
            }
        }
    }
}
