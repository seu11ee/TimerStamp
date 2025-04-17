//
//  TimerView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

import SwiftUI

struct TimeTimerView: View {
    @State private var totalSeconds: Double = 60 * 60 // 60분
    @State private var remainingSeconds: Double = 60 * 60

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 배경 원 (회색)
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            // 1분 단위 눈금 (짧은 선, 총 60개)
            ForEach(0..<60) { index in
                let angle = Angle.degrees(Double(index) * -6) // 반시계 방향
                Capsule()
                    .fill(index % 5 == 0 ? Color.black : Color.gray) // 5분 단위는 검정색으로 짙게
                    .frame(width: 2, height: index % 5 == 0 ? 12 : 6) // 5분 단위는 길이가 더 길고, 나머지는 짧음
                    .offset(y: -150 + 4) // 바깥쪽 위치 조정
                    .rotationEffect(angle)
            }
            
            // 5분 단위 눈금 (숫자 텍스트, 총 12개)
            ForEach(0..<12) { index in
                let minute = (index * 5) % 60
                let angle = Angle.degrees(Double(minute) * -6) // 북쪽을 0분으로 설정
                VStack {
                    Text("\(minute)")
                        .font(.title) // 폰트 크기
                        .foregroundColor(.black)
                        .rotationEffect(-angle) // 텍스트가 바깥쪽을 향하도록 회전
                        .offset(y: -50) // 더 바깥쪽으로 이동
                    Spacer()
                }
                .rotationEffect(angle)
                .frame(width: 280, height: 280)
            }

            // 파이 조각 (남은 시간)
            PieSlice(
                startAngle: .degrees(-90 + 360 * (1 - remainingSeconds / totalSeconds)),
                endAngle: .degrees(-90)
            )
            .fill(Color.red.opacity(0.7))

            // 텍스트로 남은 시간 표시
            Text(timeString(from: Int(remainingSeconds)))
                .font(.title)
                .monospacedDigit()
                .bold()
        }
        .frame(width: 280, height: 280)
        .onReceive(timer) { _ in
            if remainingSeconds > 0 {
                withAnimation(.linear(duration: 1)) {
                    remainingSeconds -= 1
                }
            }
        }
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
