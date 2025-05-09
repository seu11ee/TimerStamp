//
//  TimerRemainingLiveActivity.swift
//  TimerRemaining
//
//  Created by 이예슬 on 5/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerRemainingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TimerRemainingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Lock screen UI
            HStack {
                Text("집중할 시간")
                Spacer()
                Text(Self.format(seconds: context.state.remainingSeconds))
                    .monospacedDigit()
                    .bold()
            }
            .padding()
        } dynamicIsland: { context in
            
            DynamicIsland {
                // 확장된 상태 (Expanded)
                DynamicIslandExpandedRegion(.center){
                    Text("⏳")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .trailing) {
                        Text(Self.format(seconds: context.state.remainingSeconds))
                            .font(.system(size: 18, weight: .bold))
                            .monospacedDigit()
                        Text("남음")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("끝나기까지 조금만 더 집중!")
                        .font(.caption)
                }
            } compactLeading: {
                Text("⏳")
            } compactTrailing: {
                Text(Self.format(seconds: context.state.remainingSeconds))
            } minimal: {
                Text("⏳")
            }
        }
    }

    static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}


//struct TimerRemainingLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TimerRemainingAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}

extension TimerRemainingAttributes {
    fileprivate static var preview: TimerRemainingAttributes {
        TimerRemainingAttributes(name: "World")
    }
}

extension TimerRemainingAttributes.ContentState {
    fileprivate static var smiley: TimerRemainingAttributes.ContentState {
        TimerRemainingAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TimerRemainingAttributes.ContentState {
         TimerRemainingAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TimerRemainingAttributes.preview) {
   TimerRemainingLiveActivity()
} contentStates: {
    TimerRemainingAttributes.ContentState.smiley
    TimerRemainingAttributes.ContentState.starEyes
}
