//
//  MinuteTicks.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/19/25.
//
import SwiftUI

struct MinuteTicks: View {
    var radius: CGFloat  // 반지름을 외부에서 주입받기 위한 프로퍼티
    
    var body: some View {
        ForEach(0..<60) { index in
            let angle = Angle.degrees(Double(index) * -6)
            Rectangle()
                .fill(Color.playButtonEnabled)
                .frame(width: index % 5 == 0 ? 2 : 1, height: index % 5 == 0 ? 8 : 6)
                .offset(y: index % 5 == 0 ? -radius - 7 : -radius - 6)  // 외부에서 전달된 반지름 적용
                .rotationEffect(angle)
        }
    }
}
