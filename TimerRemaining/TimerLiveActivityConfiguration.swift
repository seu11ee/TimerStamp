//
//  TimerRemainingLiveActivity.swift
//  TimerRemaining
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Lock screen UI
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
            let timerText = {
                if context.state.isPaused {
                    Text(TimerLiveActivityConfiguration.format(seconds: Int(remaining)))
                } else {
                    Text(Date(timeIntervalSinceNow: remaining), style: .timer)
                }
            }()
            return DynamicIsland {
                // Expanded View (길게 눌렀을 때)
                DynamicIslandExpandedRegion(.center) {
                    LiveActivityView(context: context)
                }
            } compactLeading: {
                progressView(context: context)
            } compactTrailing: {
                timerText
            } minimal: {
                progressView(context: context)
            }
        }
    }

    static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

@ViewBuilder
func progressView(context: ActivityViewContext<TimerAttributes>) -> some View {
    if context.state.isPaused {
        let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
        let totalDuration = context.attributes.totalDuration
        ProgressView(value: Float(remaining) / Float(totalDuration))
            .progressViewStyle(.circular)
    } else {
        ProgressView(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
            .progressViewStyle(.circular)
    }
}

@ViewBuilder
func timerText(context: ActivityViewContext<TimerAttributes>) -> some View {
    if context.state.isPaused {
        Text(TimerLiveActivityConfiguration.format(seconds: Int(context.state.remainingTime)))
    } else {
        Text(Date(timeIntervalSinceNow: context.state.remainingTime), style: .timer)
    }
}
