//
//  UserNamePromptViewModel.swift
//  Pawcus
//
//  Created by 김정원 on 6/10/25.
//

import Combine
import Foundation
import Factory
import SwiftUI

final class UserNamePromptViewModel: ObservableObject {
    @Injected(\.registerUserUseCase) private var useCase: RegisterUserUseCase

    @Published var tempInput: String = ""
    @Published var isValidNickname: Bool? = nil
    @Published var statusMessage: String? = nil
    @Published var isChecking: Bool = false
    @Published var didConfirm: Bool = false
    
    var nicknameStatusImage: String? {
        if isChecking { return nil }
        if let valid = isValidNickname {
            return valid ? "checkmark.circle.fill" : "xmark.circle.fill"
        } else if statusMessage != nil {
            return "exclamationmark.triangle.fill"
        }
        return nil
    }

    var nicknameStatusColor: Color {
        if isValidNickname == nil {
            return .orange
        } else {
            return isValidNickname! ? .green : .red
        }
    }
    
    func showCancelButton() -> Bool {
        return UserDefaults.standard.string(forKey: .userNickname) != nil
    }

    /// 입력한 닉네임으로 검사
    func validate() async {
        await MainActor.run {
            isChecking = true
            isValidNickname = nil
            statusMessage = nil
        }
        do {
            let valid = try await useCase.checkNicknameAvailability(
                nickname: tempInput.trimmingCharacters(in: .whitespaces)
            )
            await MainActor.run {
                isValidNickname = valid
                statusMessage = valid
                    ? "Nickname is available."
                    : "Nickname is already taken"
                isChecking = false
            }
        } catch {
            await MainActor.run {
                statusMessage = error.localizedDescription
                isChecking = false
            }
        }
    }

    /// 닉네임 업데이트
    func confirm() async {
        let trimmed = tempInput.trimmingCharacters(in: .whitespaces)
        do {
            try await useCase.updateNickname(trimmed)
            await MainActor.run {
                didConfirm = true
            }

        } catch {
            await MainActor.run {
                statusMessage = error.localizedDescription
            }
        }
    }
}
