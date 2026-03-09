//
//  TimerControls.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

struct TimerControls: View {
    @ObservedObject var timerViewModel: TimerViewModel
    let onPhotoButtonTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if timerViewModel.state == .ended {
                PhotoCertificationButton(action: onPhotoButtonTap)
            }
            
            PlayControlButtons(timerViewModel: timerViewModel)
                .padding(.top, 12)
        }
    }
}
