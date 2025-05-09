//
//  LiveActivityManager.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit

enum LiveActivityManager {
    static func start(durationMinutes: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let totalSeconds = durationMinutes * 60
        let attributes = TimerAttributes(durationMinutes: durationMinutes)
        let state = TimerAttributes.ContentState(remainingSeconds: totalSeconds)

        do {
            let activity = try Activity<TimerAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Live Activity 시작 실패: \(error)")
        }
    }

    static func update(remainingSeconds: Int) {
        Task {
            let state = TimerAttributes.ContentState(remainingSeconds: remainingSeconds)
            for activity in Activity<TimerAttributes>.activities {
                await activity.update(using: state)
            }
        }
    }

    static func end() {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
