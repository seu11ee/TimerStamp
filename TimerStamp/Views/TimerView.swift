//
//  TimerView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI
import Combine

struct TimerView: View {
    @State private var progress: Double = 1.0
    @State private var isCompleted = false
    @State var minutes: Int = 0
    var width: CGFloat
    var height: CGFloat
    
    init(minutes: Int, width: CGFloat, height: CGFloat) {
        self.minutes = minutes
        self.width = width
        self.height = height
    }
    // TODO: - TimerView test code
    var body: some View {
        VStack(spacing: 60) {
            ZStack {
                MinuteTicks()
                MinuteLabels(width: width, height: height)
                PieSlice(progress: progress, minutes: minutes)
                    .fill(Color.red)
                    .frame(width: width, height: height)
                if isCompleted {
                    Text("⏰ Done!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                }
                MinuteDial(selectedMinute: $minutes, radius: width / 2)
            }
            Button(action: {
                let duration = Double(minutes * 60)
                withAnimation(.linear(duration: duration)) {
                    progress = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isCompleted = true
                }
            }) {
                Text("\(minutes)분")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }
        }
    }
}

struct TimeLabel: View {
    let seconds: Int
    
    var body: some View {
        Text(Self.formatTime(seconds: seconds))
            .font(.title)
            .monospacedDigit()
            .bold()
    }
    
    static func formatTime(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
