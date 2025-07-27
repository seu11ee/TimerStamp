//
//  CircularTimerView.swift
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

// MARK: - Constants
private struct TimerConstants {
    static let circlePadding: CGFloat = 60
    static let dialRadiusRatio: CGFloat = 0.83
    static let componentSpacing: CGFloat = 60
}

// MARK: - Main Timer View
struct CircularTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    private let size: CGSize
    
    init(viewModel: TimerViewModel, width: CGFloat, height: CGFloat) {
        self.viewModel = viewModel
        self.size = CGSize(width: width, height: height)
    }
    
    private var timerCircleRadius: CGFloat {
        min(size.width, size.height) / 2 - TimerConstants.circlePadding
    }
    
    var body: some View {
        VStack(spacing: TimerConstants.componentSpacing) {
            TimerCircleView(
                viewModel: viewModel,
                radius: timerCircleRadius,
                containerSize: size
            )
        }
        .onAppear {
            setupTimer()
        }
    }
    
    private func setupTimer() {
        viewModel.resetStatus()
        viewModel.restoreTimerIfNeeded()
    }
}

// MARK: - Timer Circle Composite View
struct TimerCircleView: View {
    @ObservedObject var viewModel: TimerViewModel
    let radius: CGFloat
    let containerSize: CGSize
    
    private var dialRadius: CGFloat {
        radius * TimerConstants.dialRadiusRatio
    }
    
    var body: some View {
        ZStack {
            MinuteLabels(width: containerSize.width, height: containerSize.height)
            
            TimerProgressPie(
                progress: viewModel.progress,
                minutes: viewModel.durationMinutes,
                radius: radius
            )
            
            MinuteTicks(radius: radius)
            
            TimerDial(
                durationMinutes: $viewModel.durationMinutes,
                remainingTime: $viewModel.remainingTime,
                radius: dialRadius,
                isRunning: viewModel.state == .running
            )
        }
    }
}

// MARK: - Timer Progress Pie Component
struct TimerProgressPie: View {
    let progress: Double
    let minutes: Int
    let radius: CGFloat
    
    private var diameter: CGFloat {
        radius * 2
    }
    
    var body: some View {
        PieSlice(progress: progress, minutes: minutes)
            .fill(Color.timerRed)
            .frame(width: diameter, height: diameter)
            // 필요시 섀도우 활성화
            // .shadow(radius: 5, x: 0, y: 2)
    }
}

// MARK: - Timer Dial Wrapper
struct TimerDial: View {
    @Binding var durationMinutes: Int
    @Binding var remainingTime: TimeInterval
    let radius: CGFloat
    let isRunning: Bool
    
    var body: some View {
        MinuteDial(
            durationMinutes: $durationMinutes,
            remainingTime: $remainingTime,
            radius: radius,
            isRunning: isRunning
        )
    }
}

// MARK: - Alternative Simpler Version
struct TimerViewSimple: View {
    @ObservedObject var viewModel: TimerViewModel
    let size: CGFloat
    
    private var radius: CGFloat {
        size / 2 - 60
    }
    
    var body: some View {
        ZStack {
            // 배경 요소들   
            TimerBackground(size: size)
            
            // 진행 상태 표시
            TimerProgress(
                progress: viewModel.progress,
                minutes: viewModel.durationMinutes,
                radius: radius
            )
            
            // 다이얼 컨트롤
            TimerControl(
                viewModel: viewModel,
                radius: radius * 0.83
            )
        }
        .onAppear(perform: setupTimer)
    }
    
    private func setupTimer() {
        viewModel.resetStatus()
        viewModel.restoreTimerIfNeeded()
    }
}

// MARK: - Supporting Components for Simple Version
struct TimerBackground: View {
    let size: CGFloat
    
    var body: some View {
        Group {
            MinuteLabels(width: size, height: size)
            MinuteTicks(radius: size / 2 - 60)
        }
    }
}

struct TimerProgress: View {
    let progress: Double
    let minutes: Int
    let radius: CGFloat
    
    var body: some View {
        PieSlice(progress: progress, minutes: minutes)
            .fill(Color.timerRed)
            .frame(width: radius * 2, height: radius * 2)
    }
}

struct TimerControl: View {
    @ObservedObject var viewModel: TimerViewModel
    let radius: CGFloat
    
    var body: some View {
        MinuteDial(
            durationMinutes: $viewModel.durationMinutes,
            remainingTime: $viewModel.remainingTime,
            radius: radius,
            isRunning: viewModel.state == .running
        )
    }
}

// MARK: - Usage Examples
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // 기존 방식과 동일한 인터페이스
        CircularTimerView(viewModel: TimerViewModel(), width: 350, height: 350)
            .previewDisplayName("Refactored Timer")
        
        // 더 간단한 버전
        TimerViewSimple(viewModel: TimerViewModel(), size: 350)
            .previewDisplayName("Simple Timer")
    }
}
