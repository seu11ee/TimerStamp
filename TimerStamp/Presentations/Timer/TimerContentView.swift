//
//  TimerScreenView.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/16/25.
//

import SwiftUI

struct TimerContentView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var photoViewModel: PhotoSelectionViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            CircularTimerView(viewModel: timerViewModel, width: 350, height: 350)

            if timerViewModel.state != .ended {
                Text("\(L10n.timerRotateInstruction)")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(timerViewModel.state == .idle ? .mainText : .clear)
            }
            else if timerViewModel.state == .ended {
                Text("👏 \(L10n.focusComplete(timerViewModel.durationMinutes))")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(.mainText)
            }

            if timerViewModel.state != .ended {
                TimeLabel(seconds: Int(timerViewModel.remainingTime), endDate: timerViewModel.endDate)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }

            if timerViewModel.state == .ended {
                Button(action: {
                    photoViewModel.isShowingSourceDialog = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.body)
                        Text("\(L10n.authPhoto)")
                            .font(.body)
                    }
                    .foregroundColor(.mainButtonText)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.mainButton)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                }
            }

            HStack(spacing: 80) {
                Button(action: {
                    timerViewModel.reset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 30, weight: .bold))
                        .fontWidth(.expanded)
                        .foregroundColor(.mainButtonText)
                        .background(
                            Circle()
                                .fill(.resetButtonEnabled)
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
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .fontWidth(.expanded)
                        .foregroundColor(.mainButtonText)
                        .background(
                            Circle()
                                .fill(timerViewModel.state == .ended ? Color.playButtonDisabled : Color.playButtonEnabled)
                                .frame(width: 65, height: 65)
                        )
                }
                .disabled(timerViewModel.state == .ended)
                
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}
