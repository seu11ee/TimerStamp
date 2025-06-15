//
//  OnboardingView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/12/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .center) {
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {

                Text("타이머와 인증을 통해 집중력 올리기")
                                    .font(.largeTitle)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                VStack(alignment: .leading, spacing: 32) {
                    OnboardingFeatureRow(
                        systemImage: "timer",
                        title: "다이얼을 돌리고 타이머 시작",
                        description: "원하는 시간만큼 다이얼을 돌려 집중을 시작하세요."
                    )

                    OnboardingFeatureRow(
                        systemImage: "checkmark.seal",
                        title: "집중한 후 인증 사진 만들기",
                        description: "집중을 마친 후 인증 사진을 저장하거나 공유할 수 있어요."
                    )
                }
                

                Button(action: {
                    isPresented = false
                }) {
                    Text("시작하기")
                        .frame(maxWidth: 400)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
        }
    }
}

struct OnboardingFeatureRow: View {
    var systemImage: String
    var title: String
    var description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(10)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
#Preview {
    OnboardingView(isPresented: .constant(false))
}
