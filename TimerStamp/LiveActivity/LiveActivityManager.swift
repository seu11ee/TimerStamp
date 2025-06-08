//
//  LiveActivityManager.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit
import Foundation

enum LiveActivityManager {
    static func start(startDate: Date, endDate: Date, totalDuration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let contentState = TimerAttributes.ContentState(startDate: startDate, endDate: endDate)
        let attributes = TimerAttributes(totalDuration: totalDuration)
        let staleDate = endDate.addingTimeInterval(60)
        
        print("let's start a live activity!", totalDuration, endDate)
        
        do {
            let activity = try Activity<TimerAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: staleDate),
                pushType: nil
            )
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Live Activity 시작 실패: \(error)")
        }
    }

    static func update(endDate: Date, isPaused: Bool = false) {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                let currentStartDate = activity.content.state.startDate
                let contentState = TimerAttributes.ContentState(startDate: currentStartDate, endDate: endDate, isPaused: isPaused)
                await activity.update(using: contentState)
                print("🔄 Live Activity updated: \(activity.id)")
            }
        }
    }

    static func end() {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
                print("🔚 Live Activity ended: \(activity.id)")
            }
        }
    }
}
