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
                
                MinuteLabels(width: width, height: height)

                PieSlice(
                    progress: viewModel.progress,
                    minutes: viewModel.durationMinutes
                )
                .fill(Color.red)
                .frame(width: timerCircleRadius * 2, height: timerCircleRadius * 2)
                .shadow(radius: 5, x: 0, y: 2)
                
                MinuteTicks(radius: timerCircleRadius)
                MinuteDial(durationMinutes: $viewModel.durationMinutes, progress: viewModel.progress, radius: width / 2)
            }
        }
        .onAppear {
            viewModel.restoreTimerIfNeeded()
        }
        .background(.white)
        
    }
        

    private func calculateProgress() -> Double {
        let total = Double(viewModel.durationMinutes * 60)
        return total > 0 ? Double(viewModel.remainingSeconds) / total : 1.0
    }
}
