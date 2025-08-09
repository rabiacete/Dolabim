//
//  UploadViewModel.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class UploadViewModel {

    private var selectedImage: UIImage?
    private var imagePickerDelegate: ImagePickerDelegateWrapper?

    func selectPhoto(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false

        let delegate = ImagePickerDelegateWrapper { [weak self] image in
            self?.selectedImage = image
            completion(image)
        }

        picker.delegate = delegate
        self.imagePickerDelegate = delegate // STRONG referansla saklıyoruz
        viewController.present(picker, animated: true)
    }


    func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        // Simülasyon: Gerçek API entegrasyonu sonra
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(image) // (Şimdilik) aynı görseli döndürüyoruz
        }
    }

    func saveToCloset(image: UIImage, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Kategori Seç", message: nil, preferredStyle: .actionSheet)
        CategoryType.allCases.forEach { category in
            alert.addAction(UIAlertAction(title: category.rawValue, style: .default, handler: { _ in
                let id = UUID()
                let imageName = "\(id).png"
                let product = Product(id: id, imageName: imageName, category: category)
                ProductManager.shared.saveProduct(product, image: image)
            }))
        }
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        viewController.present(alert, animated: true)
    }

}
