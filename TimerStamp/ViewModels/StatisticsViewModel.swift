//
//  StatisticsViewModel.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/5/25.
//


import Foundation
import SwiftUI
import Combine

struct DayStat: Identifiable {
    let id = UUID()
    let day: String
    let focusHours: Double
}

final class StatisticsViewModel: ObservableObject {
    @Published var totalFocusTime: String
    @Published var averageFocusTime: String
    @Published var sessionCount: Int
    @Published var timerModeDuration: String
    @Published var pomodoroModeDuration: String
    @Published var weeklyFocusData: [DayStat]
    @Published var sharedSessionImages: [UIImage]

    init(
        totalFocusTime: String = "100",
        averageFocusTime: String = "50",
        sessionCount: Int = 2,
        timerModeDuration: String = "50",
        pomodoroModeDuration: String = "50",
        weeklyFocusData: [DayStat] = [
            DayStat(day: "Mon", focusHours: 1),
            DayStat(day: "Tue", focusHours: 2),
            DayStat(day: "Wed", focusHours: 3)],
        sharedSessionImages: [UIImage] = []
    ) {
        self.totalFocusTime = totalFocusTime
        self.averageFocusTime = averageFocusTime
        self.sessionCount = sessionCount
        self.timerModeDuration = timerModeDuration
        self.pomodoroModeDuration = pomodoroModeDuration
        self.weeklyFocusData = weeklyFocusData
        self.sharedSessionImages = sharedSessionImages
    }
}
