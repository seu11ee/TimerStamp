//
//  MinuteTicks.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/19/25.
//
import SwiftUI

struct MinuteTicks: View {
    var body: some View {
        ForEach(0..<60) { index in
            let angle = Angle.degrees(Double(index) * -6)
            Capsule()
                .fill(index % 5 == 0 ? Color.black : Color.gray)
                .frame(width: 2, height: index % 5 == 0 ? 12 : 6)
                .offset(y: -146)
                .rotationEffect(angle)
        }
    }
}
