//
//  SimpleTimerView.swift
//  TimerStamp
//
//  Created by 이예슬 on 8/1/25.
//

import SwiftUI

struct SimpleTimerView: View {
    var minutes: Int
    let radius: CGFloat
    
    // 분을 기준으로 progress 계산 (전체 파이 표시용)
    private var progress: Double {
        return 1  //
    }
    
    // 분을 각도로 변환 (1분 = 6도)
    private var rotation: Double {
        return Double(minutes) * 6.0
    }
    
    var body: some View {
        ZStack {
            // 정사각형 배경 추가
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(width: radius * 3, height: radius * 3)
                .clipShape(RoundedRectangle(cornerRadius: radius/1.5))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            TimerProgressPie(
                progress: progress,
                minutes: minutes,
                radius: radius
            )
            
            RadiusStickView(radius: radius * 0.83)
                .rotationEffect(.degrees(rotation))
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    SimpleTimerView(
        minutes: 10,
        radius: 80
    )
    
}
