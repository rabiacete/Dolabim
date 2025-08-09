//
//  Product.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

struct Product: Codable {
    let id: UUID?
    let imageName: String
    let category: CategoryType

    func loadImage() -> UIImage? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = path.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: imageURL.path)
    }
}
