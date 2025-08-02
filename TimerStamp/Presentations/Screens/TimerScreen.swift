//
//  ContentView.swift
//  TimerStamp
//
//  Created by 이예슬 on 4/17/25.
//

import SwiftUI

// MARK: - 1. TimerScreen.swift (최상위 화면 - 네비게이션, 모달 등 관리)
struct TimerScreen: View {
    @AppStorage("hasLaunchedTimerStamp") private var hasLaunchedBefore: Bool = false
    @State private var showOnboarding: Bool = false
    @StateObject private var photoViewModel = PhotoSelectionViewModel()
    @StateObject private var timerViewModel = TimerViewModel()

    var body: some View {
        ZStack {
            Color.mainBackground.ignoresSafeArea()
            TimerContentView(
                timerViewModel: timerViewModel,
                photoViewModel: photoViewModel
            )

            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            }
        }
        .background(Color.mainBackground)
        .photoSelectionModals(photoViewModel: photoViewModel, timerViewModel: timerViewModel)
        .onAppear(perform: handleViewAppear)
        .onDisappear(perform: handleViewDisappear)
    }
    
    private func handleViewAppear() {
        if hasLaunchedBefore == false {
            showOnboarding = true
            hasLaunchedBefore = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    private func handleViewDisappear() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

#Preview {
    TimerScreen()
}
