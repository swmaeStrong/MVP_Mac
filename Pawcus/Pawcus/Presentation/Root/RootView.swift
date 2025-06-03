//
//  RootView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/22/25.
//

import Foundation
import SwiftUI
import Factory
import Supabase

struct RootView: View {
    @AppStorage("userNickname") private var username: String = ""
    @State private var isLoggedIn: Bool = false
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timeStore: DailyWorkTimeStore

    @State private var session: Session?

    var body: some View {
        Group {
            if isLoggedIn {
                ContentView()
                    .onAppear {
                        timeStore.context = modelContext
                    }
            } else {
                LoginView()
            }
        }
        .onAppear {
            Task {
                do {
                    self.session = try await supabase.auth.session
                    self.isLoggedIn = true
                } catch {
                    print("Failed to fetch session:", error)
                    self.isLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    RootView()
}
