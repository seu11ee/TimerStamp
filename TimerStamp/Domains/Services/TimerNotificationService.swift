//
//  TimerNotificationService.swift
//  TimerStamp
//

import Foundation

protocol TimerNotificationService {
    func requestPermission()
    func schedule(endDate: Date, durationMinutes: Int)
    func cancel()
}
