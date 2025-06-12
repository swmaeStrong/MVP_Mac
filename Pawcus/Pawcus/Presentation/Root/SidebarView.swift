//
//  SidebarView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: Tab?
    
    var body: some View {
        VStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Image(systemName: tab.imageName)
                        .foregroundStyle(selectedTab == tab ? .accent : .secondary)
                        .font(.title)
                        .padding(.vertical)
                        .frame(width: 70, height: 50)
                }
                .buttonStyle(.plain)
            }

            .padding(.top, 5)
            S
            Divider()
                .padding()
            
            Spacer()
        }
        .frame(width: 100)
        .background(Color(.windowBackgroundColor))
    }
}