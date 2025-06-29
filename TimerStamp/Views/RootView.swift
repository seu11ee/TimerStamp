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
            StatisticsView()
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
