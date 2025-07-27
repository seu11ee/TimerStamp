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

            if timerViewModel.state == .idle || timerViewModel.state == .running {
                Text("분침을 돌려 시간을 설정하세요")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(timerViewModel.state == .idle ? .mainText : .clear)
            }
            else if timerViewModel.state == .ended {
                Text("👏 \(timerViewModel.durationMinutes)분 집중 완료!")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(.mainText)
            }

            if timerViewModel.state != .ended {
                TimeLabel(seconds: Int(timerViewModel.remainingTime), endDate: timerViewModel.endDate)
                    .frame(height: 50)
            }

            if timerViewModel.state == .ended {
                Button(action: {
                    photoViewModel.isShowingSourceDialog = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.body)
                        Text("인증 사진 만들기")
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
            .padding(.top, 12)

            Spacer()
        }
    }
}
