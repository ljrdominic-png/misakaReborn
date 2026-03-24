//
//  ImageSaver.swift
//  misaka
//
//  Previously in CarPreview.swift (File Explorer).
//

import UIKit
import AlertToast

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage), nil)
    }

    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if error != nil {
                ToastController.shared.Toast_Hud = AlertToast(displayMode: .hud, type: .error(.red), title: "Save failed")
            } else {
                ToastController.shared.Toast_Hud = AlertToast(displayMode: .hud, type: .complete(.green), title: "Saved to Photos")
            }
            ToastController.shared.Show_Hud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                ToastController.shared.Show_Hud = false
            }
        }
    }
}
