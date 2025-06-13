//
//  TimerAttributes.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit
import Foundation

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endDate: Date?
        var isPaused: Bool = false
        var pausedRemainingTime: TimeInterval = 0
        var remainingTime: TimeInterval {
            guard let endDate = endDate else {
                return pausedRemainingTime
            }
            return max(0, endDate.timeIntervalSinceNow)
        }
    }

    var duration: TimeInterval
    var startDate: Date // for ProgressView

    // Preview를 위한 샘플 값
    static var preview: TimerAttributes {
        TimerAttributes(duration: 25, startDate: Date())
    }

    static var previewContentState: ContentState {
        let now = Date()
        return ContentState(endDate: now.addingTimeInterval(1500))
    }
}
