import UIKit

class ProductManager {

    static let shared = ProductManager()
    private let key = "savedProducts"

    func saveProduct(_ product: Product, image: UIImage) {
        var products = loadProducts()
        products.append(product)
        saveImage(image, with: product.imageName)
        saveProducts(products)
    }

    func saveProducts(_ products: [Product]) {
        if let data = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadProducts() -> [Product] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let products = try? JSONDecoder().decode([Product].self, from: data) else {
            return []
        }
        return products
    }

    private func saveImage(_ image: UIImage, with name: String) {
        if let data = image.pngData() {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = path.appendingPathComponent(name)
            try? data.write(to: fileURL)
        }
    }
    func deleteProduct(_ product: Product) {
        var currentProducts = loadProducts()
        currentProducts.removeAll { $0.imageName == product.imageName }
        
        if let data = try? JSONEncoder().encode(currentProducts) {
            UserDefaults.standard.set(data, forKey: key)
        }

        // İsteğe bağlı: görseli de silebiliriz
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(product.imageName)
        try? FileManager.default.removeItem(at: fileURL)
    }

}

