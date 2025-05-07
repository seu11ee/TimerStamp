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
    let timerViewWidth = UIScreen.main.bounds.width - 6
    var body: some View {
        TabView {
            VStack(spacing: 30) {
                // ✅ 타이머 뷰는 항상 표시
                TimerView(viewModel: timerViewModel, width: timerViewWidth, height: timerViewWidth)
                                    .offset(y: 30)
                Button(action: {
                    if timerViewModel.isRunning {
                        timerViewModel.reset()
                    } else {
                        timerViewModel.start()
                    }
                }) {
                    Text(timerViewModel.isRunning ? "RESET" : "START")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                }
                .offset(y: 15)

                TimeLabel(seconds: timerViewModel.remainingSeconds)
                if timerViewModel.state == .idle {
                    Button("📷 사진 선택하기") {
                        viewModel.isShowingSourceDialog = true
                    }.offset(y: 50)
                }

            }
            .confirmationDialog("사진을 어떻게 가져올까요?", isPresented: $viewModel.isShowingSourceDialog, titleVisibility: .visible) {
                Button("📸 사진 찍기") {
                    viewModel.selectSource(.camera)
                }
                Button("🖼 보관함에서 선택") {
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
                        }
                    )
                }
            }
            
            // 다른 페이지들
            ForEach(0..<1) { index in
                ZStack {
                    Color(hue: Double(index) / 5.0, saturation: 0.6, brightness: 0.9)
                    Text("Page \(index + 1)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }
                .cornerRadius(15)
                .padding()
            }
        }
        .background(Color.white) // 배경 흰색 설정
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

#Preview {
    ContentView()
}
