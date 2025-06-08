//
//  MinuteLables.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/19/25.
//

import SwiftUI

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
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .rotationEffect(-angle)
                    .offset(y: 12)
                Spacer()
            }
            .rotationEffect(angle)
            .frame(width: width, height: height)
            .clipped()
        }
    }
}
