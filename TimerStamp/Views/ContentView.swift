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
            
            if timerViewModel.state != .ended {
                TimeLabel(seconds: timerViewModel.remainingSeconds)
                    .frame(height: 50)
            }
            
            if timerViewModel.state == .ended {
                Button(action: {
                    viewModel.isShowingSourceDialog = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.body)
                        Text("인증 사진 만들기")
                            .font(.body)
                    }
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
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
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.gray)
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
                        timerViewModel.reset()
                    }
                }) {
                    Image(systemName: timerViewModel.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 65, height: 65)
                        )
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .confirmationDialog("사진을 어떻게 가져올까요?", isPresented: $viewModel.isShowingSourceDialog, titleVisibility: .visible) {
            Button("사진 찍기") {
                viewModel.selectSource(.camera)
            }
            Button("보관함에서 선택") {
                viewModel.selectSource(.photoLibrary)
            }
            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(
                image: Binding(
                    get: { viewModel.selectedImage },
                    set: { viewModel.didSelectImage($0) }
                ),
                sourceType: viewModel.sourceType
            )
        }
        // ✅ CertificationModalView로 이미지 전달
        .sheet(isPresented: $viewModel.isShowingModal) {
            if let image = viewModel.selectedImage {
                CertificationModalView(
                    baseImage: image,
                    minutes: timerViewModel.durationMinutes,
                    onDismiss: {
                        viewModel.dismissModal()
                        timerViewModel.reset()
                    }
                )
            }
        }
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
