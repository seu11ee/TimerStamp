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
            LiveActivityView(contentState: context.state)
        } dynamicIsland: { context in
            let remaining = max(0, context.state.remainingTime)
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
                    LiveActivityView(contentState: context.state)
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
        return String(format: "%2d:%02d", m, s)
    }
    
    func previewContext(_ context: any PreviewProvider) {
        
    }
}

@ViewBuilder
func progressView(context: ActivityViewContext<TimerAttributes>) -> some View {
    if context.state.isPaused {
        ProgressView(value: context.state.remainingTime / context.attributes.duration)
            .progressViewStyle(.circular)
            .tint(.red)
    } else {
        let elapsedSeconds = context.attributes.duration - context.state.remainingTime
        let adjustedStartDate = Date().addingTimeInterval(-elapsedSeconds)
        ProgressView(timerInterval: adjustedStartDate...(context.state.endDate ?? Date()), countsDown: true)
        {
            Text(verbatim: "")
        } currentValueLabel: {
            Text(verbatim: "")
        }
        .progressViewStyle(.circular)
        .tint(.red)

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
