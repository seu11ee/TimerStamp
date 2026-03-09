//
//  PlayControlButtons.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

struct PlayControlButtons: View {
    @ObservedObject var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 80) {
            Button(action: {
                timerViewModel.reset()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.mainButtonText)
                    .background(
                        Circle()
                            .fill(.playButtonEnabled)
                            .frame(width: 65, height: 65)
                    )
            }

            Button(action: {
                switch timerViewModel.state {
                case .idle:
                    timerViewModel.start()
                case .paused:
                    timerViewModel.resume()
                case .running:
                    timerViewModel.pause()
                case .ended:
                    timerViewModel.start()
                }
            }) {
                Image(systemName: timerViewModel.state == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.mainButtonText)
                    .background(
                        Circle()
                            .fill(Color.playButtonEnabled)
                            .frame(width: 65, height: 65)
                    )
            }
        }
    }
}
