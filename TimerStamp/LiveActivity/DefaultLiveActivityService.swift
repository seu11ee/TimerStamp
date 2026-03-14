//
//  DefaultLiveActivityService.swift
//  TimerStamp
//

import Foundation

final class DefaultLiveActivityService: TimerLiveActivityService {
    func start(startDate: Date, endDate: Date, totalDuration: TimeInterval) {
        LiveActivityManager.start(startDate: startDate, endDate: endDate, totalDuration: totalDuration)
    }

    func update(endDate: Date?, isPaused: Bool, pausedRemainingTime: TimeInterval) {
        LiveActivityManager.update(endDate: endDate, isPaused: isPaused, pausedRemainingTime: pausedRemainingTime)
    }

    func end() {
        LiveActivityManager.end()
    }
}
