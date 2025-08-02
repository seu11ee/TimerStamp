//
//  View+PhotoSelection.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/6/25.
//

import SwiftUI

extension View {
    func photoSelectionModals(
        @ObservedObject photoViewModel: PhotoSelectionViewModel,
        timerViewModel: TimerViewModel
    ) -> some View {
        self
            .confirmationDialog(L10n.photoSourceTitle, isPresented: $photoViewModel.isShowingSourceDialog, titleVisibility: .visible) {
                        Button(L10n.photoTakeNew) {
                            photoViewModel.selectSource(.camera)
                        }
                        Button(L10n.photoChooseLibrary) {
                            photoViewModel.selectSource(.photoLibrary)
                        }
                        Button(L10n.cancel, role: .cancel) {}
                    }
            .sheet(isPresented: $photoViewModel.isShowingImagePicker) {
                        ImagePicker(
                            image: Binding(
                                get: { photoViewModel.selectedImage },
                                set: { photoViewModel.didSelectImage($0) }
                            ),
                            sourceType: photoViewModel.sourceType
                        )
                    }
                    // ✅ CertificationModalView로 이미지 전달
                    .sheet(isPresented: $photoViewModel.isShowingModal) {
                        if let image = photoViewModel.selectedImage {
                            CertificationModalView(
                                baseImage: image,
                                minutes: timerViewModel.durationMinutes,
                                onDismiss: {
                                    photoViewModel.dismissModal()
                                    timerViewModel.reset()
                                }
                            )
                        }
                    }
    }
}
