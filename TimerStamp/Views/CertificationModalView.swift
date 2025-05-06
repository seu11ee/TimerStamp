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
                GeometryReader { geo in
                    // 배경 이미지
                    let size = 600.0
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    // 분침 (MinuteTicks에 반지름 전달)
                            MinuteTicks(radius: size / 2)  // 반지름을 전달
                                .frame(width: size, height: size)
                                .position(center)
                                .foregroundColor(.blue)  // 분침의 색상
                                .opacity(0.8)

                            // 중앙 하얀 반투명 PieSlice
                            PieSlice(progress: 1.0, minutes: minutes)
                                .fill(Color.red.opacity(0.6))
                                .frame(width: size, height: size)
                                .position(center)


                    // 중앙 PieSlice (하얗고 반투명)
                    PieSlice(progress: 1, minutes: minutes)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: size, height: size)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)

                    // 하단 텍스트
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
                .frame(width: 1000, height: 1000)
            }
            .background(Color.white)

            let renderer = ImageRenderer(content: view)
            renderer.proposedSize = .init(width: 1000, height: 1000)
            return renderer.uiImage
        }
}
