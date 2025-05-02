//
//  TimerView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()

    var width: CGFloat
    var height: CGFloat

    var body: some View {
        VStack(spacing: 60) {
            ZStack {
                MinuteTicks()
                MinuteLabels(width: width, height: height)

                PieSlice(
                    progress: calculateProgress(),
                    minutes: viewModel.durationMinutes
                )
                .fill(Color.red)
                .frame(width: width, height: height)

                if viewModel.isFinished {
                    Text("⏰ Done!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                }
                MinuteDial(selectedSeconds: $viewModel.remainingSeconds, radius: width / 2)
                    .onChange(of: viewModel.durationMinutes) { newValue in
                        if !viewModel.isRunning {
                            viewModel.reset()
                        }
                    }
            }

            Button(action: {
                if viewModel.isRunning {
                    viewModel.reset()
                } else {
                    viewModel.start()
                }
            }) {
                Text(viewModel.isRunning ? "RESET" : "START")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }
            .offset(y: 100)

            TimeLabel(seconds: viewModel.remainingSeconds)
                .offset(y: 100)
        }
        .onAppear {
            viewModel.restoreTimerIfNeeded()
        }
    }

    private func calculateProgress() -> Double {
        let total = Double(viewModel.durationMinutes * 60)
        return total > 0 ? Double(viewModel.remainingSeconds) / total : 1.0
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
