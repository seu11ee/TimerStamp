//
//  MinuteDial.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/25/25.
//

import SwiftUI

struct MinuteDial: View {
    @Binding var selectedMinute: Int
    var radius: CGFloat
    
    @GestureState private var dragRotation: Double = 0
    @State private var rotation: Double = 0
    @State private var startAngle: Double?
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: radius, y: radius)
            
            RadiusStick(radius: radius)
                .fill(Color.yellow)
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
                .rotationEffect(.degrees(rotation + dragRotation))
                .gesture(
                    DragGesture()
                        .updating($dragRotation) { value, state, _ in
                            let location = value.location
                            let vector = CGVector(dx: location.x - radius, dy: location.y - radius)
                            let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                            let adjustedAngle = angle < 0 ? angle + 360 : angle
                            
                            // 드래그 시작 시 startAngle 저장
                            if startAngle == nil {
                                let startVector = CGVector(dx: value.startLocation.x - radius, dy: value.startLocation.y - radius)
                                let start = atan2(startVector.dy, startVector.dx) * 180 / .pi
                                startAngle = start < 0 ? start + 360 : start
                            }
                            
                            if let start = startAngle {
                                let delta = adjustedAngle - start
                                state = delta
                                
                                // ✅ 드래그 중에도 selectedMinute 업데이트
                                let currentRotation = rotation + delta
                                let flooredRotation = floor(currentRotation / 6) * 6
                                let newMinute = Int((currentRotation.truncatingRemainder(dividingBy: 360)) / 6)
                                selectedMinute = (newMinute + 60) % 60
                            }
                        }
                        .onEnded { value in
                            let location = value.location
                            let vector = CGVector(dx: location.x - radius, dy: location.y - radius)
                            let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                            let adjustedAngle = angle < 0 ? angle + 360 : angle
                            
                            if let start = startAngle {
                                let delta = adjustedAngle - start
                                rotation += delta
                                startAngle = nil
                                let flooredRotation = floor(rotation / 6) * 6
                                // 분 계산 (각도 / 6도 = 1분)
                                let newMinute = Int(((rotation).truncatingRemainder(dividingBy: 360)) / 6)
                                selectedMinute = (newMinute + 60) % 60
                            }
                        }
                )
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}


struct RadiusStick: Shape {
    var radius: CGFloat
    var stickWidth: CGFloat = 4
    
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
