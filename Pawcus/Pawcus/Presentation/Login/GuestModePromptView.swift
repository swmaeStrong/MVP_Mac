//
//  GuestModePromptView.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation
import SwiftUI
import Factory

struct GuestModePromptView: View {
    @Injected(\.registerUserUseCase) private var useCase: RegisterUserUseCase
    @State private var tempInput: String = ""
    @State private var isValidNickname: Bool? = nil
    @State private var isChecking: Bool = false
    @State private var statusMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Please enter a nickname")
                .font(.title2)
            HStack {
                TextField("Nickname", text: $tempInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tempInput) {
                        isValidNickname = nil
                        statusMessage = nil
                    }

                Button("Check availability") {
                    Task {
                        await validateNickname()
                    }
                }
                .disabled(tempInput.trimmingCharacters(in: .whitespaces).isEmpty || isChecking)
            }

            HStack {
                if isChecking {
                    ProgressView().scaleEffect(0.5)
                } else if let isValid = isValidNickname {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValid ? .green : .red)
                }

                if let message = statusMessage {
                    Text(message)
                        .foregroundColor((isValidNickname ?? false) ? Color.green : .red)
                        .font(.footnote)
                }
            }

            Button("Start") {
                Task {
                    do {
                        let trimmedNickname = tempInput.trimmingCharacters(in: .whitespaces)
                        try await useCase.registerUser(nickname: trimmedNickname)
                        UserDefaults.standard.set(0, forKey: "dailyWorkSeconds")
                    } catch {
                        statusMessage = error.localizedDescription
                    }
                }
            }
            .disabled(!(isValidNickname ?? false))
        }
        .padding()
        .frame(width: 300)
    }

    func validateNickname() async {
        isChecking = true
        isValidNickname = nil
        statusMessage = nil
        do {
            let valid = try await useCase.checkNicknameAvailability(nickname: tempInput.trimmingCharacters(in: .whitespaces))
            isValidNickname = valid
            statusMessage = valid ? "Nickname is available." : "Nickname is already taken."
        } catch {
            statusMessage = error.localizedDescription
        }
        isChecking = false
    }
}
