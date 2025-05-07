//
//  PieSlice.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct PieSlice: Shape {
    var progress: Double // 1.0 → 0.0
    var minutes: Int     // 입력된 분 (1 ~ 59)
    
    // 애니메이션 가능
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
//    func path(in rect: CGRect) -> Path {
//        let totalDegrees = Double(minutes) * 6.0 // 1분 = 6도
//        let start = Angle.degrees(-90 + totalDegrees * progress)
//        let end = Angle.degrees(-90)
//
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//
//        path.move(to: center)
//        path.addArc(center: center,
//                    radius: radius,
//                    startAngle: start,
//                    endAngle: end,
//                    clockwise: true)
//        path.closeSubpath()
//
//        return path
//    }
    
    func path(in rect: CGRect) -> Path {
        let totalDegrees = Double(minutes) * 6.0
        let start = Angle.degrees(-90 + totalDegrees * progress)
        let end = Angle.degrees(-90)

        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: start,
                    endAngle: end,
                    clockwise: true)
        path.closeSubpath()

        // 그림자 선 추가
        let endX = center.x + CGFloat(cos(start.radians)) * radius
        let endY = center.y + CGFloat(sin(start.radians)) * radius
        path.move(to: center)
        path.addLine(to: CGPoint(x: endX, y: endY))

        return path
    }
}
