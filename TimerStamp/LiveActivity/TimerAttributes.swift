//
//  TimerAttributes.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
    }

    var durationMinutes: Int
    
    // Preview를 위한 샘플 값
    static var preview: TimerAttributes {
        TimerAttributes(durationMinutes: 25)
    }

    static var previewContentState: ContentState {
        ContentState(remainingSeconds: 300)
    }
}
