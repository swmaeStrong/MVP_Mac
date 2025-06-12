//
//  TimerButton.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/18/25.
//

import SwiftUI

struct TimerButton: View {
    @EnvironmentObject private var timeStore: DailyWorkTimeStore
    
    var body: some View {
        Image(systemName: timeStore.isRunning ? "stop.fill" : "play.fill")
            .font(.largeTitle)
            .frame(width: 70, height: 50)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [timeStore.isRunning ? .red : .indigo, timeStore.isRunning ? .pink.opacity(0.5) : .blue.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                timeStore.isRunning ? timeStore.stop() : timeStore.start()
            }
            .padding()
    }
}