//
//  RootView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI
import Factory

struct RootView: View {
    @AppStorage("userNickname") private var username: String = ""
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    var body: some View {
        if username.isEmpty {
            UsernamePromptView()
        } else {
            ContentView()
                .onAppear {
                    timeStore.context = modelContext
                }
        }
    }
}

struct UsernamePromptView: View {
    @Injected(\.registerUserUseCase) private var useCase: RegisterUserUseCase
    @State private var tempInput: String = ""
    @State private var isValidNickname: Bool? = nil
    @State private var isChecking: Bool = false
    @State private var statusMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Text("닉네임을 입력해주세요")
                .font(.title2)
            HStack {
                TextField("닉네임", text: $tempInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tempInput) {
                        isValidNickname = nil
                        statusMessage = nil
                    }
                    
                Button("중복 확인") {
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
                        .foregroundColor((isValidNickname ?? false) ? Color(red: 0.0, green: 0.5, blue: 0.0) : .red)
                        .font(.footnote)
                }
            }
            
            Button("시작하기") {
                Task {
                    do {
                        let trimmedNickname = tempInput.trimmingCharacters(in: .whitespaces)
                        let uuid = UUID().uuidString
                        try await useCase.register(uuid: uuid, nickname: trimmedNickname)
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
            let valid = try await useCase.isNicknameValid(nickname: tempInput.trimmingCharacters(in: .whitespaces))
            isValidNickname = valid
            statusMessage = valid ? "사용 가능한 닉네임입니다." : "이미 사용 중인 닉네임입니다."
        } catch {
            statusMessage = error.localizedDescription
        }
        isChecking = false
    }
}

#Preview {
    RootView()
}
