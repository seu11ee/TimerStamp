//
//  RootView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/29/25.
//

import SwiftUI

struct RootView: View {
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            let mockViewModel = StatisticsViewModel(
                totalFocusTime: "8시간 30분",
                averageFocusTime: "1시간 12분",
                sessionCount: 12,
                timerModeDuration: "5시간",
                pomodoroModeDuration: "3시간 30분",
                weeklyFocusData: [
                    .init(day: "월", focusHours: 0),
                    .init(day: "화", focusHours: 0),
                    .init(day: "수", focusHours: 0),
                    .init(day: "목", focusHours: 0),
                    .init(day: "금", focusHours: 0),
                    .init(day: "토", focusHours: 0.1),
                    .init(day: "일", focusHours: 0.1)
                ],
                sharedSessionImages: (1...7).compactMap {
                    UIImage(named: "s\($0)")
                }
            )
            StatisticsView(viewModel: mockViewModel)
                .navigationDestination(for: String.self) { value in
                    if value == "timer" {
                        ContentView()
                    }
                }
                
        }
        .onAppear {
            DispatchQueue.main.async {
                path.append("timer")
            }
        }
    }
}

#Preview {
    RootView()
}
