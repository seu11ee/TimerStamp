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

    var body: some View {
        VStack(spacing: 24) {
            Text("인증 사진")
                .font(.title2)
                .bold()

            if let image = composedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else {
                ProgressView("이미지를 렌더링 중입니다...")
                    .frame(height: 300)
            }

            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Text("닫기")
                        .frame(maxWidth: .infinity)
                }

                Button(action: saveImage) {
                    Text("이미지 저장")
                        .frame(maxWidth: .infinity)
                }
                .disabled(composedImage == nil)

                Button(action: { showShareSheet = true }) {
                    Text("공유하기")
                        .frame(maxWidth: .infinity)
                }
                .disabled(composedImage == nil)
            }
            .frame(height: 44)
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)

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
    }

    func saveImage() {
        guard let image = composedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

enum ComposedImageRenderer {
    @MainActor
    static func render(image: UIImage, minutes: Int) -> UIImage? {
        let view = ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            PieSlice(progress: 0, minutes: minutes)
                .fill(Color.red.opacity(0.4))

            VStack {
                Spacer()
                HStack {
                    Text("⏱ \(minutes)분 완료!")
                        .font(.headline)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    Text(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
                        .font(.caption)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
        }
        .frame(width: 1000, height: 1000) // 캔버스 크기 고정
        .background(Color.white)

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: 1000, height: 1000)
        return renderer.uiImage
    }
}
