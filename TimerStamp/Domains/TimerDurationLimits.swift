//
//  TimerDurationLimits.swift
//  TimerStamp
//
//  타이머 설정 시간 규칙 (requirements.json DIAL-2).
//  범위를 바꿀 때는 minutesRange 한 곳만 고친다 — 다이얼 각도 범위와 ViewModel clamp가 모두 여기서 나온다.
//

import Foundation

enum TimerDurationLimits {
    /// 설정 가능한 분 범위. 다이얼 한 바퀴(360°)가 60분이므로 상한은 60을 넘을 수 없다.
    static let minutesRange: ClosedRange<Int> = 1...60

    /// 범위 밖 값을 가장 가까운 경계값으로 맞춘다.
    static func clamped(_ minutes: Int) -> Int {
        min(max(minutes, minutesRange.lowerBound), minutesRange.upperBound)
    }
}
