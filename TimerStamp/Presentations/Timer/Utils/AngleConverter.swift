//
//  AngleConverter.swift
//  TimerStamp
//
//  타이머 시간(분/초) ↔ 원형 다이얼 각도(도) 변환 유틸리티.
//  1분 = 6도 (360도 / 60분)
//

import Foundation

enum AngleConverter {
    /// 분을 다이얼 각도(도)로 변환합니다.
    static func minutesToDegrees(_ minutes: Int) -> Double {
        return Double(minutes) * 6.0
    }

    /// 초를 다이얼 각도(도)로 변환합니다.
    static func secondsToDegrees(_ seconds: TimeInterval) -> Double {
        return seconds / 10.0
    }
}
