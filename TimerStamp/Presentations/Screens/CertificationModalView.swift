//
//  CertificationModalView.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/6/25.
//

import SwiftUI

struct CertificationModalView: View {
    var baseImage: UIImage
    var minutes: Int
    var onDismiss: () -> Void
    @State private var hasRendered = false
    @State private var composedImage: UIImage?
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("인증 사진")
                .font(.title2)
                .foregroundStyle(.mainText)
            
            if let image = composedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(color: .mainText.opacity(0.2), radius: 2)
            } else {
                ProgressView("이미지를 렌더링 중입니다...")
                    .frame(height: 300)
            }
            
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Text("닫기")
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                
                Button(action: saveImage) {
                    Text("이미지 저장")
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                .disabled(composedImage == nil)
                
                Button(action: {
                    showShareSheet = true
                }) {
                    Text("공유하기")
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                .disabled(composedImage == nil)
            }
            .frame(height: 44)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .overlay {
            Color.clear
                .onAppear {
                    if !hasRendered {
                        hasRendered = true
                        DispatchQueue.main.async {
                            if let image = ComposedImageRenderer.render(image: baseImage, minutes: minutes) {
                                DispatchQueue.main.async {
                                    composedImage = image
                                }
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = composedImage {
                ActivityView(activityItems: [image])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .imageSaveCompleted)) { notification in
            if let success = notification.object as? Bool {
                showSaveConfirmation = true
            }
        }
        .alert("완료", isPresented: $showSaveConfirmation) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("이미지가 저장되었습니다!")
        }
        .background(Color.mainBackground)
    }
    
    func saveImage() {
        guard let image = composedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, ImageSaveHelper.shared, #selector(ImageSaveHelper.didFinishSaving(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

class ImageSaveHelper: NSObject {
    static let shared = ImageSaveHelper()
    var onSaveCompletion: ((Bool) -> Void)?
    
    @objc func didFinishSaving(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            let success = (error == nil)
            NotificationCenter.default.post(name: .imageSaveCompleted, object: success)
        }
    }
}

extension Notification.Name {
    static let imageSaveCompleted = Notification.Name("imageSaveCompleted")
}

enum ComposedImageRenderer {
    @MainActor
    static func render(image: UIImage, minutes: Int) -> UIImage? {
        let view = ZStack {
            GeometryReader { geo in
                let size = 400.0
                let center = CGPoint(x: size / 2 + 50, y: geo.size.height - size / 2 - 50.0)
                
                // 1. 원본 이미지
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                // 2. 어두운 오버레이
                Color.black.opacity(0.1)
                    .frame(width: geo.size.width, height: geo.size.height)
                
                // 3. CircularTimerView를 흐리게 오버레이
                CircularTimerView(viewModel: TimerViewModel(durationMinutes: minutes), width: size, height: size)
                    .frame(width: size, height: size) // 명확한 크기 지정
                    .clipShape(RoundedRectangle(cornerRadius: size / 4)) // 코너 라운딩
                    .overlay( // 테두리 오버레이 추가
                        RoundedRectangle(cornerRadius: size / 4)
                            .inset(by: -5)
                            .stroke(.timerStroke, lineWidth: 17) // 테두리 색상 및 두께
                    )
                    .shadow(radius: 10)
                    .position(center) // 위치 지정
                
                // 4. 하단 텍스트
                HStack {
                    Spacer()
                    VStack(alignment: .trailing){
                        Spacer()
                        Text("✨ \(minutes)분 집중 완료!")
                            .font(.system(size: 62, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer().frame(height: 50)
                    }
                }
                .padding(.trailing, 16)
                
            }
            .frame(width: 1080, height: 1920)
        }
            .background(Color.white)
        
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(CGSize(width: 1080, height: 1920))
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

#Preview {
    CertificationModalView(
        baseImage: UIImage(systemName: "camera") ?? UIImage(),
        minutes: 59,
        onDismiss: {}
    )
}
