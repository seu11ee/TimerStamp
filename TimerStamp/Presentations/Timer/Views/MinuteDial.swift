//
//  MinuteDial.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/25/25.
//

import SwiftUI
import UIKit

/// 회전 가능한 시계 분침 컴포넌트.
/// 각도(0~360°)만 알고, 시간/분 등 도메인 개념과 무관하게 동작합니다.
struct MinuteDial: View {

    /// 현재 다이얼 각도 (0~360°). 외부에서 읽기/쓰기 가능.
    @Binding var angle: Double

    /// 드래그 스냅 단위(도). 기본값 6° = 타이머 1분 단위.
    var snapStep: Double = 6.0

    var radius: CGFloat
    var isRunning: Bool

    // MARK: - Internal State

    private struct DragState {
        var delta: Double = 0
        var startAngle: Double? = nil
        var lastHapticAngle: Double? = nil
        var isActive: Bool = false
    }

    @GestureState private var dragState = DragState()

    /// 제스처 계산의 기준이 되는 안정적인 각도.
    /// angle 바인딩이 외부에서 변경될 때(타이머 진행 등) 동기화됩니다.
    @State private var committedAngle: Double = 0

    // MARK: - Body

    var body: some View {
        RadiusStickView(radius: radius)
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(committedAngle + dragState.delta))
            .gesture(isRunning ? nil : dragGesture)
            .onAppear {
                committedAngle = angle
            }
            .onChange(of: angle) { _, newValue in
                guard !dragState.isActive else { return }
                committedAngle = newValue
            }
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                if state.startAngle == nil {
                    state.startAngle = pointToAngle(value.startLocation)
                }
                guard let start = state.startAngle else { return }

                let delta = pointToAngle(value.location) - start
                state.delta = delta
                state.isActive = true

                let snapped = snapToStep(committedAngle + delta)
                if snapped != state.lastHapticAngle {
                    state.lastHapticAngle = snapped
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }
            .onEnded { value in
                let start = pointToAngle(value.startLocation)
                let end = pointToAngle(value.location)
                committedAngle = snapToStep(committedAngle + (end - start))
                angle = committedAngle
            }
    }

    // MARK: - Helpers (internal for testability)

    /// CGPoint를 원의 중심 기준 각도(0~360°)로 변환합니다.
    func pointToAngle(_ point: CGPoint) -> Double {
        let dx = Double(point.x - radius)
        let dy = Double(point.y - radius)
        let raw = atan2(dy, dx) * 180 / .pi
        return raw < 0 ? raw + 360 : raw
    }

    /// 각도를 snapStep 배수로 내림합니다.
    func snapToStep(_ rotation: Double) -> Double {
        return floor(rotation / snapStep) * snapStep
    }
}

// MARK: - Preview

#Preview("드래그 테스트") {
    struct PreviewWrapper: View {
        @State private var angle: Double = 150   // 25분 (150 = 25 * 6)
        @State private var isRunning: Bool = false
        private let radius: CGFloat = 115

        private var displayMinutes: Int {
            let minute = Int(angle / 6.0)
            return (minute + 60) % 60
        }

        var body: some View {
            VStack(spacing: 32) {
                ZStack {
                    TimerProgressPie(
                        progress: angle / 360,
                        minutes: displayMinutes,
                        radius: radius
                    )
                    MinuteDial(
                        angle: $angle,
                        snapStep: 6.0,
                        radius: radius * 0.83,
                        isRunning: isRunning
                    )
                }
                .frame(width: radius * 2, height: radius * 2)

                VStack(spacing: 6) {
                    Text("각도: \(Int(angle))°")
                        .font(.title2.monospacedDigit())
                    Text("분: \(displayMinutes)분")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Text(isRunning ? "🔒 드래그 잠김 (Running)" : "✅ 드래그 가능 (Idle)")
                        .font(.caption)
                        .foregroundStyle(isRunning ? .orange : .green)
                }

                VStack(spacing: 12) {
                    Toggle("Running 상태", isOn: $isRunning)
                        .padding(.horizontal)

                    Button("⏱ -6° (-1분)") {
                        angle = max(0, angle - 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isRunning)

                    Button("↺ 리셋 (25분)") {
                        isRunning = false
                        angle = 150
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
