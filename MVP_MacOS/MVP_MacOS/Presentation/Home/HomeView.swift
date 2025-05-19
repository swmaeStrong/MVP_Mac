//
//  HomeView.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Foucs Log")
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .bold()
            Text("💻 ..")
                .font(.title2)
            
            ZStack {
                Circle()
                    .fill(Color.black.opacity(1))
                    .frame(width: 250, height: 250)
                    .shadow(color: .green.opacity(0.8), radius: 60, x: 0, y: 0)
                VStack {
                    Text(viewModel.formattedTime)
                        .font(.largeTitle)
                        .bold()
                        .monospaced()
                        .foregroundColor(.green)
                    Button(action: {
                        viewModel.toggleTimer()
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundColor(.white)
    }
}

#Preview {
    HomeView()
}
