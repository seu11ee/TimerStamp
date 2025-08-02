//
//  TimerLabel.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/8/25.
//

import SwiftUI

struct TimeLabel: View {
    let seconds: Int
    let endDate: Date?
    
    var timeText: some View {
        guard let endDate = endDate else { return Text("\(TimeLabel.formatTime(seconds: seconds))") }
        return Text(endDate, style: .timer)
    }
    
    var body: some View {
        timeText
        .font(.title)
        .monospacedDigit()
        .fontWeight(.bold)
        .fontWidth(.expanded)
        .kerning(-2)
    }
    
    static func formatTime(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%2d:%02d", m, s)
    }
}
