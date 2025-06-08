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
        var startDate: Date
        var endDate: Date
        var isPaused: Bool = false

        var remainingTime: TimeInterval {
            max(0, endDate.timeIntervalSinceNow)
        }

        var progress: Double {
            let total = endDate.timeIntervalSince(startDate)
            let elapsed = total - remainingTime
            return total > 0 ? min(1.0, elapsed / total) : 0
        }
    }

    var totalDuration: TimeInterval
    
    // Preview를 위한 샘플 값
    static var preview: TimerAttributes {
        TimerAttributes(totalDuration: 25)
    }

    static var previewContentState: ContentState {
        let now = Date()
        return ContentState(startDate: now, endDate: now.addingTimeInterval(1500))
    }
}
