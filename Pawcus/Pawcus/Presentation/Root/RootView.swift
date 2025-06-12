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
    @AppStorage(UserDefaultKey.isLoggedIn.rawValue) private var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn  {
            ContentView()
                .frame(minWidth: 450, minHeight: 500)
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
