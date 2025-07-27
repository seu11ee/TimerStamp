//
//  StatisticsView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/29/25.
//

import SwiftUI

struct StatisticsView: View {
    @State private var path: [String] = []
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        NavigationStack(path: $path) {
            if #available(iOS 26.0, *) {
                ZStack {
                    Color(.systemGray5)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) { //카드뷰
                            // Section 1: 시간 통계
                            Text("이번 주 통계")
                                .font(.title2).bold()
                            VStack(alignment: .leading, spacing: 12) {
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("총 집중 시간")
                                            .font(.title3).bold()
                                        Text(viewModel.totalFocusTime)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("평균 집중 시간")
                                            .font(.title3).bold()
                                        Text(viewModel.averageFocusTime)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("세션 수")
                                            .font(.title3).bold()
                                        Text("\(viewModel.sessionCount)회")
                                            .font(.headline)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Section 2: 모드별 비교
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("타이머 모드")
                                            .font(.title3).bold()
                                        Text(viewModel.timerModeDuration)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("뽀모도로 모드")
                                            .font(.title3).bold()
                                        Text(viewModel.pomodoroModeDuration)
                                            .font(.headline)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Section 3: 요일별 집중 시간
                            VStack(alignment: .leading, spacing: 12) {
                                Text("요일별 집중 시간")
                                    .font(.title3).bold()
                                
                                let maxFocus = viewModel.weeklyFocusData.map(\.focusHours).max() ?? 1
                                
                                HStack(alignment: .bottom) {
                                    ForEach(viewModel.weeklyFocusData, id: \.day) { stat in
                                        Spacer(minLength: 0)
                                        VStack {
                                            Text(stat.focusHours <= 0 ? "0h" : String(format: "%.1fh", stat.focusHours))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(width: 16, height: CGFloat(stat.focusHours / maxFocus) * 120)
                                                .animation(.easeInOut(duration: 0.5), value: stat.focusHours)
                                            Text(stat.day)
                                                .font(.caption)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            // Section 4: 공유한 세션
                            VStack(alignment: .leading, spacing: 10) {
                                Text("공유한 세션")
                                    .font(.title2).bold()
                                    .padding(.bottom, 8)
                                
                                if viewModel.sharedSessionImages.isEmpty {
                                    Text("없음")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                        ForEach(viewModel.sharedSessionImages, id: \.self) { image in
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(9/16, contentMode: .fill)
                                                .clipped()
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding()
                        .padding(.top, 8)
                    }
                }
                .navigationTitle("통계")
                .navigationDestination(for: String.self) { value in
                    if value == "timer" {
                        MainTimerView()
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        NavigationLink(value: "timer") {
                            Image(systemName: "timer")
                        }
//                        .glassEffect()
                    }
                    
                }
                

            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#Preview {
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
    return StatisticsView(viewModel: mockViewModel)
}
