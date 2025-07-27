//
//  View+PhotoSelection.swift
//  TimerStamp
//
//  Created by 이예슬 on 7/27/25.
//

import SwiftUI

extension View {
    func photoSelectionModals(
        photoViewModel: PhotoSelectionViewModel,
        timerViewModel: TimerViewModel
    ) -> some View {
        self
            .confirmationDialog(
                "사진을 어떻게 가져올까요?",
                isPresented: .constant(photoViewModel.isShowingSourceDialog),
                titleVisibility: .visible
            ) {
                Button("사진 찍기") {
                    photoViewModel.selectSource(.camera)
                }
                Button("보관함에서 선택") {
                    photoViewModel.selectSource(.photoLibrary)
                }
                Button("취소", role: .cancel) {}
            }
            .sheet(isPresented: .constant(photoViewModel.isShowingImagePicker)) {
                ImagePicker(
                    image: Binding(
                        get: { photoViewModel.selectedImage },
                        set: { photoViewModel.didSelectImage($0) }
                    ),
                    sourceType: photoViewModel.sourceType
                )
            }
            .sheet(isPresented: .constant(photoViewModel.isShowingModal)) {
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
