//
//  GuestModePromptView.swift
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Please enter a nickname")
                    .font(.title2)
                HStack {
                    TextField("Nickname", text: $vm.tempInput)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: vm.tempInput) {
                            vm.isValidNickname = nil
                            vm.statusMessage = nil
                        }
                    
                    Button("Check") {
                        Task { await vm.validate() }
                    }
                    .disabled(vm.tempInput.trimmingCharacters(in: .whitespaces).isEmpty || vm.isChecking)
                }
                if let message = vm.statusMessage {
                    HStack {
                        if vm.isChecking {
                            ProgressView().scaleEffect(0.5)
                        } else if let image = vm.nicknameStatusImage {
                            Image(systemName: image)
                                .foregroundColor(vm.nicknameStatusColor)
                        }
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(vm.nicknameStatusColor)
                    }
                }
            }
            .padding()
            .frame(width: 300)
            .toolbar {
                if vm.showCancelButton() {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        Task {
                            await vm.confirm()
                        }
                    }
                    .disabled(!(vm.isValidNickname ?? false))
                }
            }
        }
        .onReceive(vm.$didConfirm) { didConfirm in
            if didConfirm {
                dismiss()
            }
        }
    }
}
