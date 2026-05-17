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
