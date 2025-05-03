//
//  RadiusStick.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/3/25.
//

import SwiftUI

struct RadiusStick: Shape {
    var radius: CGFloat
    var stickWidth: CGFloat = 8
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 막대의 시작점과 끝점 계산
        let start = center
        let end = CGPoint(x: center.x, y: center.y - radius) // 위쪽 방향으로 radius만큼
        
        // 막대 그리기
        path.move(to: start)
        path.addLine(to: end)
        
        return path.strokedPath(.init(lineWidth: stickWidth, lineCap: .round))
    }
}
