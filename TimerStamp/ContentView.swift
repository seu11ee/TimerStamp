//
//  ContentView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ForEach(0..<2) { index in
                ZStack {
                    Color(hue: Double(index) / 5.0, saturation: 0.6, brightness: 0.9)
                    Text("Page \(index + 1)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }
                .cornerRadius(15)
                .padding()
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // 페이지 스타일 적용
    }
}

#Preview {
    ContentView()
}
