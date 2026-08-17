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
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                landscapeBody(containerSize: geo.size)
            } else {
                portraitBody
            }
        }
    }

    private var portraitBody: some View {
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
                certPhotoButton
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
            }

            HStack(spacing: 80) {
                resetButton
                playPauseButton
            }
            .padding(.top, 12)

            Spacer()
        }
    }

    private func landscapeBody(containerSize: CGSize) -> some View {
        let dialSize = min(containerSize.height * 0.85, containerSize.width * 0.45)

        // 다이얼+라벨을 한 그룹(전체 폭 차지)으로 묶어야 우측 버튼 레이어의 폭과
        // 무관하게 이 그룹이 항상 화면 정중앙에 위치함
        return HStack {
            Spacer()
            .frame(maxWidth: .infinity)
            
            VStack {
                Spacer()

                CircularTimerView(viewModel: timerViewModel, width: dialSize, height: dialSize)
                Spacer()
                if timerViewModel.state == .ended {
                    certPhotoButton
                } else {
                    TimeLabel(seconds: Int(timerViewModel.remainingTime), endDate: timerViewModel.endDate)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 50) {
                resetButton
                playPauseButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        }
    }
    
    private var certPhotoButton: some View {
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
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color.mainButton)
            .cornerRadius(10)
        }
    }

    private var resetButton: some View {
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
    }

    private var playPauseButton: some View {
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
}
