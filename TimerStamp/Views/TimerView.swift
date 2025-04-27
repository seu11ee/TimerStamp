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
    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?
    
    var width: CGFloat
    var height: CGFloat
    
    init(minutes: Int, width: CGFloat, height: CGFloat) {
        self.minutes = minutes
        self.width = width
        self.height = height
        _remainingSeconds = State(initialValue: minutes * 60)
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
                    .onChange(of: minutes) { newMinutes in
                                            // minutes가 바뀔 때마다 seconds를 업데이트
                                            remainingSeconds = newMinutes * 60
                                        }
            }
            Button(action: startTimer) {
                Text("\(minutes)분")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }
            // 남은 시간 보여주기
            TimeLabel(seconds: remainingSeconds)
                                .offset(y: 100)
        }
    }
    private func startTimer() {
            remainingSeconds = minutes * 60
            progress = 1.0
            isCompleted = false
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    withAnimation(.linear(duration: 1.0)) {
                        progress = Double(remainingSeconds) / Double(minutes * 60)
                    }
                } else {
                    timer?.invalidate()
                    isCompleted = true
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
