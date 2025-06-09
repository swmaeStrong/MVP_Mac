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
        if !username.isEmpty  {
            ContentView()
                .onAppear {
                    timeStore.context = modelContext
                }
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
