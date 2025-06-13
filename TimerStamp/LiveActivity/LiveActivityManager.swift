//
//  LiveActivityManager.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit
import Foundation

enum LiveActivityManager {
    static var staleInterval: TimeInterval = 600
    static func start(startDate: Date, endDate: Date, totalDuration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let contentState = TimerAttributes.ContentState(endDate: endDate)
        let attributes = TimerAttributes(duration: totalDuration, startDate: startDate)
        let staleDate = endDate
                
        do {
            let _ = try Activity<TimerAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: staleDate),
                pushType: nil
            )
        } catch {
            print("failed to start live Activity : \(error)")
        }
    }

    static func update(endDate: Date?, isPaused: Bool = false, pausedRemainingTime: TimeInterval = 0) {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                let contentState = TimerAttributes.ContentState(endDate: endDate, isPaused: isPaused, pausedRemainingTime: pausedRemainingTime)
                print("pausedInterval", pausedRemainingTime)
                let content = ActivityContent<TimerAttributes.ContentState>(state: contentState, staleDate: endDate ?? Date().addingTimeInterval(staleInterval))
                await activity.update(content)
            }
        }
    }

    static func end() {
        Task {
            for activity in Activity<TimerAttributes>.activities {
                await activity.end(activity.content, dismissalPolicy: .immediate)
            }
        }
    }
}
