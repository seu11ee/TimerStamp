//
//  ImageSaveService.swift
//  TimerStamp
//

import UIKit

final class ImageSaveService: NSObject {
    static let shared = ImageSaveService()

    @objc func didFinishSaving(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            let success = (error == nil)
            NotificationCenter.default.post(name: .imageSaveCompleted, object: success)
        }
    }
}

extension Notification.Name {
    static let imageSaveCompleted = Notification.Name("imageSaveCompleted")
}
