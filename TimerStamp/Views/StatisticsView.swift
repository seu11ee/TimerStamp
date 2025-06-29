//
//  StatisticsView.swift
//  TimerStamp
//
//  Created by 이예슬 on 6/29/25.
//

import SwiftUI

struct StatisticsView: View {
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.systemGray5)
                    .ignoresSafeArea()

                VStack {
                    // 통계 내용
                    Text("집중 통계 📊")
                        .font(.largeTitle)
                    // ...
                }
            }
            .navigationTitle("통계")
            .navigationDestination(for: String.self) { value in
                if value == "timer" {
                    ContentView()
                }
            }
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbarBackground(Color.white, for: .bottomBar)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()

                    NavigationLink(value: "timer") {
                        Image(systemName: "timer")
                            .font(.title2)
                    }
                }
            }
        }
        
    }
}

#Preview {
    return StatisticsView()
}
