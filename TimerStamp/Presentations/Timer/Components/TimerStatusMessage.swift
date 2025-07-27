//
//  TimerStatusMessage.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

struct TimerStatusMessage: View {
    let state: TimerState
    let durationMinutes: Int
    
    var body: some View {
        Group {
            switch state {
            case .idle, .running:
                Text("분침을 돌려 시간을 설정하세요")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(state == .idle ? .mainText : .clear)
            case .ended:
                Text("👏 \(durationMinutes)분 집중 완료!")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(.mainText)
            case .paused:
                EmptyView()
            }
        }
    }
}
