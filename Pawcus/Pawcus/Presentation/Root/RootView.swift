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
            LoginView()
        } else {
            ContentView()
                .onAppear {
                    timeStore.context = modelContext
                }
        }
    }
}

#Preview {
    RootView()
}
