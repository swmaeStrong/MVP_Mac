//
//  RootView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI

struct RootView: View {
    @AppStorage("username") private var username: String = ""

    var body: some View {
        if username.isEmpty {
            UsernamePromptView()
        } else {
            ContentView()
        }
    }
}

struct UsernamePromptView: View {
    @AppStorage("username") private var username: String = ""
    @State private var tempInput: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("닉네임을 입력해주세요")
                .font(.title2)
            TextField("닉네임", text: $tempInput)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("시작하기") {
                username = tempInput.trimmingCharacters(in: .whitespaces)
            }
            .disabled(tempInput.isEmpty)
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    RootView()
}
