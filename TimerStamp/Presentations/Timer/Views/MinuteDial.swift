//
//  MinuteDial.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/25/25.
//

import SwiftUI
import UIKit

/// 회전 가능한 원형 다이얼 컴포넌트.
/// 각도(0~360°)만 알고, 시간/분 등 도메인 개념과 무관하게 동작합니다.
struct MinuteDial: View {

    /// 현재 다이얼 각도 (0~360°).
    /// - 외부 → MinuteDial: 타이머 진행 등 외부 값 반영
    /// - MinuteDial → 외부: 드래그 중 실시간으로 스냅된 각도 방출
    @Binding var angle: Double

    /// 드래그 스냅 단위(도). 기본값 6° = 타이머 1분 단위.
    var snapStep: Double = 6.0

    var radius: CGFloat
    var isRunning: Bool

    // MARK: - Internal State

    /// 프레임 간 incremental delta로 wrap-around 처리 + 클램핑을 위한 드래그 임시 상태.
    private struct DragState: Equatable {
        var isActive: Bool = false
        var startCommittedAngle: Double = 0
        var previousPointer: Double = 0
        var cumulativeDelta: Double = 0
        var visualAngle: Double = 0   // 화면 회전에 사용 (연속적)
        var snappedAngle: Double = 0  // 외부로 방출하는 스냅 각도
        var lastHapticAngle: Double? = nil
    }

    @GestureState private var dragState = DragState()

    /// 제스처가 없을 때 회전 기준각.
    @State private var committedAngle: Double = 0

    /// 드래그 종료 시점에 @GestureState가 리셋되기 전 마지막 스냅 각도를 보존.
    @State private var lastSnapped: Double = 0

    // MARK: - Body

    var body: some View {
        RadiusStickView(radius: radius)
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(dragState.isActive ? dragState.visualAngle : committedAngle))
            .gesture(isRunning ? nil : dragGesture)
            .onAppear {
                committedAngle = angle
                lastSnapped = angle
            }
            .onChange(of: angle) { _, newValue in
                // 드래그 중엔 외부 변경을 무시해 이중 회전 방지
                guard !dragState.isActive else { return }
                committedAngle = newValue
                lastSnapped = newValue
            }
            .onChange(of: dragState.snappedAngle) { _, newValue in
                // 드래그 중 실시간으로 스냅 각도를 외부에 방출
                guard dragState.isActive else { return }
                lastSnapped = newValue
                angle = newValue
            }
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                // 첫 프레임: 기준값 캡처
                if !state.isActive {
                    state.startCommittedAngle = committedAngle
                    state.previousPointer = pointToAngle(value.startLocation)
                    state.cumulativeDelta = 0
                    state.isActive = true
                }

                // 프레임 간 최단 경로 delta로 0/360° wrap-around 처리
                let currentPointer = pointToAngle(value.location)
                let step = shortestDelta(state.previousPointer, currentPointer)
                state.previousPointer = currentPointer

                // 클램핑: cumulativeDelta를 조정해 경계 초과 방지
                let raw = state.startCommittedAngle + state.cumulativeDelta + step
                let clamped = max(0, min(360, raw))
                state.cumulativeDelta = clamped - state.startCommittedAngle

                state.visualAngle = clamped
                state.snappedAngle = snapToStep(clamped)

                if state.snappedAngle != state.lastHapticAngle {
                    state.lastHapticAngle = state.snappedAngle
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }
            .onEnded { _ in
                // @GestureState는 onEnded 시점에 이미 리셋되므로 lastSnapped 사용
                committedAngle = lastSnapped
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
        floor(rotation / snapStep) * snapStep
    }

    /// 두 각도 사이의 최단 경로 delta를 [-180, 180] 범위로 반환합니다.
    /// 프레임 간 소량 이동에서 0/360° 경계 wrap-around를 올바르게 처리합니다.
    private func shortestDelta(_ from: Double, _ to: Double) -> Double {
        var delta = to - from
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
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
                    MinuteDial(
                        angle: $angle,
                        snapStep: 6.0,
                        radius: radius * TimerConstants.dialRadiusRatio,
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
