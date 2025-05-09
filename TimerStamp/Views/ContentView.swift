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
        GeometryReader { geo in
            let timerViewWidth = min(geo.size.width, geo.size.height) * 0.9
            let isLandscape = geo.size.width > geo.size.height
            
            TabView {
                Group {
                    if isLandscape {
                        HStack(spacing: 30) {
                            TimerView(viewModel: timerViewModel, width: timerViewWidth, height: timerViewWidth)
                            
                            VStack(spacing: 20) {
                                resetOrStartButton
                                
                                TimeLabel(seconds: timerViewModel.remainingSeconds)
                                    .opacity(timerViewModel.state == .running ? 1 : 0)
                                
                                if timerViewModel.state == .ended {
                                    Button("📷 인증 사진 만들기") {
                                        viewModel.isShowingSourceDialog = true
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 60) {
                            TimerView(viewModel: timerViewModel, width: timerViewWidth, height: timerViewWidth)
                            
                            resetOrStartButton
                            
                            TimeLabel(seconds: timerViewModel.remainingSeconds)
                                .opacity(timerViewModel.state != .ended ? 1 : 0)
                            
                            if timerViewModel.state == .ended {
                                Button("📷 인증 사진 만들기") {
                                    viewModel.isShowingSourceDialog = true
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    // confirmationDialog, sheet 등 기존 modifier 그대로 아래에 두세요
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
                                timerViewModel.reset()
                            }
                        )
                    }
                }
            }
            .background(Color.white) // 배경 흰색 설정
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
    }
    
    private var resetOrStartButton: some View {
        Group {
            switch timerViewModel.state {
            case .idle:
                Button("START") {
                    timerViewModel.start()
                }
                
            case .running, .ended:
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
}
