//
//  RenderViewWithPie.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/6/25.
//

import SwiftUI

struct RenderViewWithPie: View {
    var image: UIImage
    var minutes: Int
    var onRendered: (UIImage) -> Void

    var body: some View {
        ZStack {
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
        .background(Color.white)
        .onAppear {
            let renderer = ImageRenderer(content: self)
            if let uiImage = renderer.uiImage {
                onRendered(uiImage)
            }
        }
    }
}
