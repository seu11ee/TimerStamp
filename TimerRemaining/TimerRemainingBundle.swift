//
//  TimerRemainingBundle.swift
//  TimerRemaining
//
//  Created by 이예슬 on 5/9/25.
//

import WidgetKit
import SwiftUI

@main
struct TimerRemainingBundle: WidgetBundle {
    var body: some Widget {
        TimerRemaining()
        TimerRemainingControl()
        TimerRemainingLiveActivity()
    }
}
