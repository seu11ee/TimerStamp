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
struct TimerConstants {
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
        viewModel.restoreOnAppear()
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
        let viewState = viewModel.dialViewState
        ZStack {
            MinuteLabels(width: containerSize.width, height: containerSize.height)

            TimerProgressPie(
                progress: viewState.progress,
                minutes: viewState.durationMinutes,
                radius: radius
            )

            MinuteTicks(radius: radius)

            TimerDial(
                displayAngle: viewState.dialAngle,
                isInteractive: viewState.isInteractive,
                radius: dialRadius,
                onUserDrag: { viewModel.setDurationMinutes($0) }
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
            .fill(Color.timerMain)
            .frame(width: diameter, height: diameter)
            // 필요시 섀도우 활성화
            // .shadow(radius: 5, x: 0, y: 2)
    }
}

// MARK: - Timer Dial Wrapper
/// MinuteDial을 타이머 맥락에서 사용하기 위한 래퍼.
///
/// IN  : displayAngle (ViewModel이 계산한 표시 각도), isInteractive, radius
/// OUT : onUserDrag  (유저가 드래그했을 때 새 분 값을 콜백으로 전달)
struct TimerDial: View {
    let displayAngle: Double
    let isInteractive: Bool
    let radius: CGFloat
    var onUserDrag: (Int) -> Void

    @State private var angle: Double = 0

    var body: some View {
        MinuteDial(
            angle: $angle,
            snapStep: 6.0,
            radius: radius,
            
            isRunning: !isInteractive
        )
        .animation(.easeInOut(duration: 0.3), value: isInteractive)
        .onAppear {
            angle = displayAngle
        }
        .onChange(of: displayAngle) { _, newAngle in
            // ViewModel이 각도를 바꾸면 반영 (카운트다운, reset 복원 등)
            // 드래그 중 외부 변경은 MinuteDial 내부에서 무시됨
            angle = newAngle
        }
        .onChange(of: angle) { _, newAngle in
            // 유저 드래그일 때만 ViewModel에 알림
            guard isInteractive else { return }
            onUserDrag(Int(newAngle / 6.0))
        }
    }
}

// MARK: - Preview

#Preview {
    CircularTimerView(viewModel: TimerViewModel(), width: 350, height: 350)
}
