//
//  ContentView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoSelectionViewModel()
    let timerView: TimerView = TimerView(viewModel: TimerViewModel(), width: 280, height: 280)
    var body: some View {
        TabView {
            VStack(spacing: 30) {
                // ✅ 타이머 뷰는 항상 표시
                timerView
                    .offset(y: 30)
                // ✅ 타이머가 ended 상태일 때만 버튼 표시
                if timerView.viewModel.state == .idle {
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
                        minutes: 30,
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
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

#Preview {
    ContentView()
}
