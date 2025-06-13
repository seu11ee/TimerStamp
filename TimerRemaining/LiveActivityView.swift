//
//  LiveActivityView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/1/25.
//

import SwiftUI
import WidgetKit

private extension View {
    func circularButtonStyle() -> some View {
        self
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(Circle().fill(Color.gray))
    }
}

struct LiveActivityView: View {
    let contentState: TimerAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            // Reset 버튼
            Image(systemName: "arrow.counterclockwise")
                .circularButtonStyle()
                .padding(.leading, 20)
            // 상태 버튼 (Pause / Resume)
            Image(systemName: contentState.isPaused ? "play.fill" : "pause.fill")
                .circularButtonStyle()
            Spacer()
            // 남은 시간
            var remainingText: Text {
                if contentState.isPaused {
                    return Text(timeString(from: contentState.remainingTime))
                }
                return Text(Date(timeIntervalSinceNow: contentState.remainingTime), style: .timer)
            }
            
            remainingText
                .font(.system(size: 28, weight: .medium))
                .monospacedDigit()
                .foregroundColor(Color(.label))
                .frame(minWidth: 80)
                .layoutPriority(100)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.black)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    LiveActivityView(contentState: TimerAttributes.previewContentState)
}
