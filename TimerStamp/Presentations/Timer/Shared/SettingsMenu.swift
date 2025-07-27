//
//  SettingsMenu.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

struct SettingsMenu: View {
    var body: some View {
        Menu {
            Button("환경설정 1") { }
            Button("환경설정 2") { }
        } label: {
            Image(systemName: "gearshape")
        }
    }
}
