//
//  LiveActivityView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/1/25.
//

import SwiftUI
import WidgetKit

struct LiveActivityView: View {
    let context: ActivityViewContext<TimerAttributes>
    
    var body: some View {
        let remaining = max(0, context.state.endDate.timeIntervalSinceNow)

        HStack(spacing: 32) {
            Image(systemName: "clock")
                .font(.title)
                .foregroundColor(.accentColor)

            if context.state.isPaused {
                Button(action: {
                    // Placeholder for resume action
                }) {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .background(Circle().fill(Color(.systemGray5)))
                }
            } else {
                Button(action: {
                    // Placeholder for pause action
                }) {
                    Image(systemName: "pause.fill")
                        .font(.title)
                        .background(Circle().fill(Color(.systemGray5)))
                }
            }
            if context.state.isPaused {
                Text(timeString(from: remaining))
            } else {
                Text(Date(timeIntervalSinceNow: remaining), style: .timer)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    private func timeString(from interval: TimeInterval) -> String {
            let minutes = Int(interval) / 60
            let seconds = Int(interval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
}
