//
//  ContentView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoSelectionViewModel()
    @StateObject private var timerViewModel = TimerViewModel()
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            TimerView(viewModel: timerViewModel, width: 350, height: 350)
                .padding(.top, 40)

            ZStack {
                if timerViewModel.state == .idle {
                    Text("분침을 돌려 시간을 설정하세요")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.black)
                }
                else if timerViewModel.state == .ended {
                    Text("👏 \(timerViewModel.durationMinutes)분 집중 완료!")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.black)
                }
                else {
                    Text("분침을 돌려 시간을 설정하세요")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.clear)
                }
            }

            TimeLabel(seconds: timerViewModel.remainingSeconds)
                .font(.system(size: 32, weight: .medium))

            HStack(spacing: 60) {
                Button(action: {
                    timerViewModel.reset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
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
                        timerViewModel.reset()
                    }
                }) {
                    Image(systemName: timerViewModel.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                }
            }

            Spacer()
        }
        .background(Color.white)
    }
    
    private var resetOrStartButton: some View {
        Group {
            switch timerViewModel.state {
            case .idle:
                Button("START") {
                    timerViewModel.start()
                }
            case .paused:
                Button("RESUME") {
                    timerViewModel.resume()
                }
            case .running:
                Button("PAUSE") {
                    timerViewModel.pause()
                }
            case .ended:
                Button("RESET") {
                    timerViewModel.reset()
                }
            }
        }
        .font(.title)
        .bold()
        .foregroundColor(.black)
        .buttonStyle(.bordered)
    }
}


#Preview {
    ContentView()
//    let size = UIScreen.main.bounds.width - 30
//    TimerView(viewModel: TimerViewModel(durationMinutes: 25), width: size, height: size)
//        .frame(width: size, height: size) // 명확한 크기 지정
//        .clipShape(RoundedRectangle(cornerRadius: size / 4)) // 코너 라운딩
//        .overlay( // 테두리 오버레이 추가
//            RoundedRectangle(cornerRadius: size / 4)
//                .stroke(Color.black, lineWidth: 17) // 테두리 색상 및 두께
//                .opacity(0.7)
//        )
}
