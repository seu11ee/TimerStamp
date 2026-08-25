//
//  MinuteLables.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/19/25.
//

import SwiftUI

/// 0-60분을 5분 단위 원형으로 표시하는 View
struct MinuteLabels: View {
    var width: CGFloat = 280
    var height: CGFloat = 280
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ForEach(0..<12) { index in
            let minute = (index * 5) % 60
            let angle = Angle.degrees(Double(minute) * 6)
            VStack {
                Text("\(minute)")
                    .font(.system(size: 23, weight: .black))
                    .fontWidth(.expanded)
                    .kerning(-2)
                    .foregroundColor(.mainButton)
                    .rotationEffect(-angle)
                    .offset(y: 9)
                Spacer()
            }
            .rotationEffect(angle)
            .frame(width: width, height: height)
            .clipped()
        }
    }
}
