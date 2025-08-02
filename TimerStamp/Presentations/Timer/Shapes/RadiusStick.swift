//
//  RadiusStick.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/3/25.
//

import SwiftUI

struct RadiusStick: Shape {
    var radius: CGFloat
    var stickWidth: CGFloat = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let end = CGPoint(x: center.x, y: center.y - radius)

        path.move(to: center)
        path.addLine(to: end)

        return path.strokedPath(.init(lineWidth: stickWidth, lineCap: .square))
    }
}

struct RadiusStickView: View {
    var radius: CGFloat
    var stickWidth: CGFloat = 10
    var centerDotRadius: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadiusStick(radius: radius, stickWidth: stickWidth)
                    .foregroundColor(.normalGray)
                // 중심 원은 항상 위에 있도록 ZStack의 마지막에 위치
                Circle()
                    .fill(.normalGray)
                    .frame(width: centerDotRadius * 2, height: centerDotRadius * 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}
