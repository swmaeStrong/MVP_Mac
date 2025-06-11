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
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    
    var body: some View {
        if isLoggedIn  {
            ContentView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
