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
            Text(L10n.certTitle)
                .font(.title2)
                .foregroundStyle(.mainText)
            
            if let image = composedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(color: .mainText.opacity(0.2), radius: 2)
            } else {
                ProgressView(L10n.certRendering)
                    .frame(height: 300)
            }
            
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Text(L10n.certClose)
                        .foregroundColor(.mainButtonText)
                        .padding(9)
                        .frame(maxWidth: .infinity)
                        .background(Color.mainButton)
                        .cornerRadius(10)
                }
                
                Button(action: saveImage) {
                    Text(L10n.certSaveImage)
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
                    Text(L10n.certShare)
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
        .alert(L10n.done, isPresented: $showSaveConfirmation) {
            Button(L10n.ok, role: .cancel) { }
        } message: {
            Text(L10n.photoSaveSuccess)
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
                let timerSize = 400.0
                let radius = timerSize / 3.4
                let margin: CGFloat = 60
                
                // 1. 원본 이미지
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                // 2. 그라데이션 오버레이
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.3)
                    ]),
                    startPoint: UnitPoint(x: 0.5, y: 0.7),
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: geo.size.height)
                
                // 3. 절대 위치로 하단 정렬
                ZStack(alignment: .bottom) {
                    Color.clear
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        // 좌측: 타이머
                        VStack(alignment: .leading) {
                            SimpleTimerView(minutes: minutes, radius: radius)
                                .opacity(0.74)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .padding(66)
                        }
                        
                        Spacer(minLength: 20)
           
                        VStack(alignment: .trailing) {
                            Text("✨ \(L10n.focusComplete(minutes))")
                                .font(.system(size: 66, weight: .heavy))
                                .fontWidth(.expanded)
                                .kerning(-2)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(nil)
                                .padding(.bottom, 6)
                            
                            Text(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
                                .font(.system(size: 58, weight: .light))
                                .foregroundColor(.white.opacity(0.95))
                                .padding(.bottom, 10)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .padding(.horizontal, margin)
                    .padding(.bottom, margin)
                }
            }
            .frame(width: 1080, height: 1920)
        }
        .background(Color.clear)
        
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(CGSize(width: 1080, height: 1920))
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

#Preview {
    Group {
        CertificationModalView(
            baseImage: UIImage(named: "s2") ?? UIImage(),
            minutes: 45,
            onDismiss: {}
        )
        .environment(\.locale, .init(identifier: "en"))
        .previewDisplayName("English")
        
//        CertificationModalView(
//            baseImage: UIImage(named: "s2") ?? UIImage(),
//            minutes: 45,
//            onDismiss: {}
//        )
//        .environment(\.locale, .init(identifier: "ko"))
//        .previewDisplayName("한국어")
//        
//        CertificationModalView(
//            baseImage: UIImage(named: "s2") ?? UIImage(),
//            minutes: 45,
//            onDismiss: {}
//        )
//        .environment(\.locale, .init(identifier: "ja"))
//        .previewDisplayName("日本語")
    }
}
