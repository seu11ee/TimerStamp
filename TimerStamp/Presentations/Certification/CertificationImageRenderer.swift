//
//  CertificationImageRenderer.swift
//  TimerStamp
//

import SwiftUI
import UIKit

enum CertificationImageRenderer {
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
