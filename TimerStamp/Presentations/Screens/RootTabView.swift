//
//  RootTabView.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/16/25.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TimerScreen()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
        }
    }
}

#Preview {
    RootTabView()
}
