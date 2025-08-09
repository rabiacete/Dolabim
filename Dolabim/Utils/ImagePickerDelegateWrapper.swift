//
//  ImagePickerDelegateWrapper.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class ImagePickerDelegateWrapper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        completion(image)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil)
        picker.dismiss(animated: true)
    }
}
