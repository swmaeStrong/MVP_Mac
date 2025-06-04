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
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var session: Session?
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timeStore: DailyWorkTimeStore

    var body: some View {
        Group {
            // isLoggedIn(게스트 모드) 또는 session(로그인 세션) 둘 중 하나라도 있으면 ContentView로 이동
            if isLoggedIn || session != nil {
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
                } catch {
                    print("Failed to fetch session:", error)
                    self.session = nil
                }
            }
        }
    }
}

#Preview {
    RootView()
}
