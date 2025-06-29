//
//  ContentView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasLaunchedTimerStamp") private var hasLaunchedBefore: Bool = false
    @State private var showOnboarding: Bool = false
    @StateObject private var viewModel = PhotoSelectionViewModel()
    @StateObject private var timerViewModel = TimerViewModel()
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                TimerView(viewModel: timerViewModel, width: 350, height: 350)
                
                if timerViewModel.state == .idle {
                    Text("분침을 돌려 시간을 설정하세요")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.mainText)
                }
                else if timerViewModel.state == .ended {
                    Text("👏 \(timerViewModel.durationMinutes)분 집중 완료!")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.mainText)
                }
                else {
                    Text("분침을 돌려 시간을 설정하세요")
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.clear)
                }
                
                if timerViewModel.state != .ended {
                    TimeLabel(seconds: Int(timerViewModel.remainingTime), endDate: timerViewModel.endDate)
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
            if showOnboarding == true {
                 OnboardingView(isPresented: $showOnboarding)
            }
        }
        .navigationTitle("타임")
        .background(Color.mainBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("환경설정 1") { /* 설정 액션 */ }
                    Button("환경설정 2") { /* 설정 액션 */ }
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
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
        .onAppear {
            if hasLaunchedBefore == false {
                showOnboarding = true
                hasLaunchedBefore = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
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
    .foregroundColor(.mainButton)
    .buttonStyle(.bordered)
}
}


#Preview {
    ContentView()
}
