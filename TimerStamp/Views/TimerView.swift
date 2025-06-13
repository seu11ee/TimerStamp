//
//  TimerView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

enum TimerState {
    case idle
    case running
    case ended
    case paused
}

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel

    var width: CGFloat
    var height: CGFloat
    
    var timerCircleRadius: CGFloat {
        width / 2 - 60
    }

    var body: some View {
        VStack(spacing: 60) {
            ZStack {
                Color.mainBackground
                    .ignoresSafeArea()
                MinuteLabels(width: width, height: height)

                PieSlice(
                    progress: viewModel.progress,
                    minutes: viewModel.durationMinutes
                )
                .fill(Color.timerRed)
                .frame(width: timerCircleRadius * 2, height: timerCircleRadius * 2)
                .shadow(radius: 5, x: 0, y: 2)
                
                MinuteTicks(radius: timerCircleRadius)
                MinuteDial(durationMinutes: $viewModel.durationMinutes, remainingTime: $viewModel.remainingSeconds, radius: timerCircleRadius * 0.9)
            }
        }
        .onAppear {
            viewModel.resetStatus()
            viewModel.restoreTimerIfNeeded()
        }
        .background(.white)
        
    }
        

    private func calculateProgress() -> Double {
        let total = Double(viewModel.durationMinutes * 60)
        return total > 0 ? Double(viewModel.remainingSeconds) / total : 1.0
    }
}
