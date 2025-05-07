//
//  MinuteDial.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/25/25.
//

import SwiftUI

struct MinuteDial: View {
    @Binding var durationMinutes: Int
    var progress: Double
    var radius: CGFloat
    
    @GestureState private var dragRotation: Double = 0
    @GestureState private var isDragging = false
    @State private var rotation: Double = 0
    @State private var startAngle: Double?
    @State private var totalSeconds: Int = 3600
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: radius, y: radius)
            
            RadiusStickView(radius: radius)
                .frame(width: radius * 2, height: radius * 2)
                .shadow(radius: 4)
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
                                let newMinute = Int((flooredRotation.truncatingRemainder(dividingBy: 360)) / 6)
                                durationMinutes = (newMinute + 60) % 60
                            }
                        }
                        .updating($isDragging) { _, state, _ in
                            state = true  // 제스처가 진행 중일 때만 true
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
                                rotation = floor(rotation / 6) * 6
                                // 분 계산 (각도 / 6도 = 1분)
                                let newMinute = Int(((rotation).truncatingRemainder(dividingBy: 360)) / 6)
                                durationMinutes = (newMinute + 60) % 60
                            }
                        }
                )
        }
        .frame(width: radius * 2, height: radius * 2)
        .onAppear {
            rotation = Double(durationMinutes) * 6
        }
        .onChange(of: progress) { newValue in
            withAnimation(.linear(duration: 1)) {
                if !isDragging {
                    print("rotation 갱신")
                    rotation = progress * Double(durationMinutes) * 6
                }
            }
        }
    }
    
}
