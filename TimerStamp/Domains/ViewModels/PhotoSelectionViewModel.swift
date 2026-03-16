//
//  PhotoSelectionViewModel.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/6/25.
//

import SwiftUI

enum PhotoSourceType {
    case camera
    case photoLibrary
}

class PhotoSelectionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var isShowingModal = false
    @Published var isShowingSourceDialog = false
    @Published private(set) var selectedSourceType: PhotoSourceType = .photoLibrary

    /// 인증사진 플로우 완료(모달 닫기) 시 호출됩니다.
    /// TimerViewModel.reset 등을 주입해 View 레이어의 협력 로직을 제거합니다.
    var onCertificationCompleted: (() -> Void)?

    func didSelectImage(_ image: UIImage?) {
        selectedImage = image
        if image != nil {
            isShowingModal = true
        }
    }

    func dismissModal() {
        isShowingModal = false
        selectedImage = nil
        onCertificationCompleted?()
    }

    func selectSource(_ source: PhotoSourceType) {
        selectedSourceType = source
        isShowingImagePicker = true
    }
}
