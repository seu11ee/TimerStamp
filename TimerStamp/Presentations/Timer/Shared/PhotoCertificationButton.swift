//
//  PhotoCertificationButton.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

struct PhotoCertificationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "camera")
                    .font(.body)
                Text("인증 사진 만들기")
                    .font(.body)
            }
            .foregroundColor(.mainButtonText)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.mainButton)
            .cornerRadius(10)
            .padding(.horizontal, 30)
        }
    }
}
