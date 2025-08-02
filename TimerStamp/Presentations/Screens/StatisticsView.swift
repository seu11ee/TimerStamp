////
////  StatisticsView.swift
////  TimerStamp
////
////  Created by 이예슬 on 6/29/25.
////
//
//import SwiftUI
//
//struct StatisticsView: View {
//    @State private var path: [String] = []
//    @ObservedObject var viewModel: StatisticsViewModel
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            if #available(iOS 26.0, *) {
//                ZStack {
//                    Color(.systemGray5)
//                        .ignoresSafeArea()
//                    
//                    ScrollView {
//                        VStack(spacing: 24) {
//                            // 이번 주 통계 섹션
//                            VStack(alignment: .leading, spacing: 16) {
//                                HStack {
//                                    Text(L10n.weeklyStats)
//                                        .font(.title2)
//                                        .bold()
//                                    Spacer()
//                                }
//                                
//                                HStack(spacing: 20) {
//                                    VStack(alignment: .leading) {
//                                        Text(L10n.totalFocusTime)
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text(viewModel.totalFocusTime)
//                                            .font(.title3)
//                                            .bold()
//                                    }
//                                    
//                                    VStack(alignment: .leading) {
//                                        Text(L10n.averageFocusTime)
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text(viewModel.averageFocusTime)
//                                            .font(.title3)
//                                            .bold()
//                                    }
//                                    
//                                    VStack(alignment: .leading) {
//                                        Text(L10n.sessionCount)
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text("\(viewModel.sessionCount)")
//                                            .font(.title3)
//                                            .bold()
//                                    }
//                                    Spacer()
//                                }
//                                
//                                HStack(spacing: 20) {
//                                    VStack(alignment: .leading) {
//                                        Text(L10n.timerMode)
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text(viewModel.timerModeDuration)
//                                            .font(.title3)
//                                            .bold()
//                                    }
//                                    
//                                    VStack(alignment: .leading) {
//                                        Text(L10n.pomodoroMode)
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text(viewModel.pomodoroModeDuration)
//                                            .font(.title3)
//                                            .bold()
//                                    }
//                                    Spacer()
//                                }
//                            }
//                            .padding()
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(12)
//                            
//                            // 요일별 집중 시간 차트
//                            VStack(alignment: .leading, spacing: 16) {
//                                Text(L10n.dailyFocusTime)
//                                    .font(.title2)
//                                    .bold()
//                                
//                                // 간단한 막대 차트
//                                VStack(spacing: 8) {
//                                    ForEach(viewModel.weeklyFocusData, id: \.day) { stat in
//                                        HStack {
//                                            Text(stat.day)
//                                                .frame(width: 30, alignment: .leading)
//                                            
//                                            GeometryReader { geo in
//                                                RoundedRectangle(cornerRadius: 4)
//                                                    .fill(Color.accentColor)
//                                                    .frame(width: CGFloat(stat.focusHours) * geo.size.width, height: 20)
//                                            }
//                                            .frame(height: 20)
//                                            
//                                            Text("\(String(format: "%.1f", stat.focusHours))h")
//                                                .font(.caption)
//                                                .frame(width: 40, alignment: .trailing)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(12)
//                            
//                            // 공유한 세션
//                            VStack(alignment: .leading, spacing: 16) {
//                                Text(L10n.sharedSessions)
//                                    .font(.title2)
//                                    .bold()
//                                
//                                if viewModel.sharedSessionImages.isEmpty {
//                                    Text(L10n.none)
//                                        .foregroundColor(.secondary)
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                        .padding(.vertical, 20)
//                                } else {
//                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
//                                        ForEach(viewModel.sharedSessionImages, id: \.self) { image in
//                                            Image(uiImage: image)
//                                                .resizable()
//                                                .aspectRatio(9/16, contentMode: .fill)
//                                                .clipped()
//                                                .cornerRadius(8)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(12)
//                        }
//                        .padding()
//                        .padding(.top, 8)
//                    }
//                }
//                .navigationTitle(L10n.statistics)
//                .navigationDestination(for: String.self) { value in
//                    if value == "timer" {
//                        TimerScreen()
//                    }
//                }
//                .toolbar {
//                    ToolbarItemGroup(placement: .bottomBar) {
//                        Spacer()
//                        
//                        NavigationLink(value: "timer") {
//                            Image(systemName: "timer")
//                        }
////                        .glassEffect()
//                    }
//                    
//                }
//                
//
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//}
//
//#Preview {
//    let mockViewModel = StatisticsViewModel(
//        totalFocusTime: "8시간 30분",
//        averageFocusTime: "1시간 12분",
//        sessionCount: 12,
//        timerModeDuration: "5시간",
//        pomodoroModeDuration: "3시간 30분",
//        weeklyFocusData: [
//            .init(day: "월", focusHours: 0),
//            .init(day: "화", focusHours: 0),
//            .init(day: "수", focusHours: 0),
//            .init(day: "목", focusHours: 0),
//            .init(day: "금", focusHours: 0),
//            .init(day: "토", focusHours: 0.1),
//            .init(day: "일", focusHours: 0.1)
//        ],
//        sharedSessionImages: (1...7).compactMap {
//            UIImage(named: "s\($0)")
//        }
//    )
//    return StatisticsView(viewModel: mockViewModel)
//}
