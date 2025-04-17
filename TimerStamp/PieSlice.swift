//
//  PieSlice.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)

        path.addArc(
            center: center,
            radius: min(rect.width, rect.height) / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.closeSubpath()
        return path
    }

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }
}

struct CircularLine: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle - .degrees(90),
            endAngle: endAngle - .degrees(90),
            clockwise: false
        )

        return path.strokedPath(.init(lineWidth: lineWidth, lineCap: .round))
    }
}

struct RingTimerShape: Shape {
    var progress: Double  // 0.0 ~ 1.0

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let endAngle = Angle.degrees(progress * 360)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(center: center,
                    radius: radius,
                    startAngle: .degrees(-90),
                    endAngle: endAngle - .degrees(90),
                    clockwise: false)

        return path
    }
}
