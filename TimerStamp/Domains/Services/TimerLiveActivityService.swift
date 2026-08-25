//
//  TimerLiveActivityService.swift
//  TimerStamp
//

import Foundation

protocol TimerLiveActivityService {
    func start(startDate: Date, endDate: Date, totalDuration: TimeInterval)
    func update(endDate: Date?, isPaused: Bool, pausedRemainingTime: TimeInterval)
    func end()
}
