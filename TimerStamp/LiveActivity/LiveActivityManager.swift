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
                
        do {
            let activity = try Activity<TimerAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: staleDate),
                pushType: nil
            )
        } catch {
            print("failed to start live Activity : \(error)")
        }
    }

    static func update(endDate: Date, isPaused: Bool = false) {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                let currentStartDate = activity.content.state.startDate
                let contentState = TimerAttributes.ContentState(startDate: currentStartDate, endDate: endDate, isPaused: isPaused)
                await activity.update(using: contentState)
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
