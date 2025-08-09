import UIKit

class ClosetViewController: UIViewController {

    // MARK: - UI
    private let categoryScrollView = UIScrollView()
    private let categoryStackView = UIStackView()

    private let productsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: 80, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private let combinationAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appCard
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appBorder.cgColor
        return view
    }()

    // MARK: - Data
    private var allProducts: [Product] = []
    private var filteredProducts: [Product] = []
    private var selectedCategory: CategoryType? = nil
    private var addedToCombination: [UIImageView] = []

    // Drag state (koleksiyondan sürükleme için)
    private var dragPreviewImageView: UIImageView?
    private var dragPreviewOriginalCenter: CGPoint = .zero
    private var draggingImageName: String?

    // Combinations ekranından gelen kombin (opsiyonel)
    private var incomingCombination: Combination?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dolabım"
        view.backgroundColor = .appBeigeBG

        setupCategoryScroll()
        setupCollectionView()
        setupCombinationArea()
        loadProducts()
        filterProducts()

        view.addSubview(saveCombinationButton)
        saveCombinationButton.addTarget(self, action: #selector(saveCombinationTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            saveCombinationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveCombinationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveCombinationButton.widthAnchor.constraint(equalToConstant: 200),
            saveCombinationButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Koleksiyondan sürükle-bırak için uzun basma gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCollectionLongPress(_:)))
        productsCollectionView.addGestureRecognizer(longPress)
    }

    // Combinations ekranından çağrılacak
    public func loadCombination(_ combination: Combination) {
        incomingCombination = combination
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let comb = incomingCombination {
            // Eğer yeni yapıyla kaydedildiyse parça parça yerleştir
            if let items = comb.items, !items.isEmpty {
                placeItems(items)
            } else if let name = comb.imageNames.first {
                // Eski kayıt: tek PNG göster
                placeSavedCombination(imageName: name)
            }
            incomingCombination = nil
        }
    }

    // MARK: - Save Button
    private let saveCombinationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kombini Kaydet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBrown
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UI Setup
    private func setupCategoryScroll() {
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 8
        categoryStackView.alignment = .center

        view.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)

        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 60),

            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -16),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor)
        ])

        CategoryType.allCases.enumerated().forEach { (index, category) in
            let button = UIButton(type: .system)
            button.setTitle(nil, for: .normal)

            // Assets’ten özel ikon
            let img = UIImage(named: category.iconName)?.withRenderingMode(.alwaysTemplate)
            button.setImage(img, for: .normal)
            button.tintColor = .black
            button.imageView?.contentMode = .scaleAspectFit

            // Yuvarlak arka plan
            button.backgroundColor = .appCard
            button.layer.cornerRadius = 22
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appBorder.cgColor
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            button.tag = index
            categoryStackView.addArrangedSubview(button)
        }
    }

    private func setupCollectionView() {
        view.addSubview(productsCollectionView)
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        productsCollectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)

        NSLayoutConstraint.activate([
            productsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            productsCollectionView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 8),
            productsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            productsCollectionView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupCombinationArea() {
        view.addSubview(combinationAreaView)
        NSLayoutConstraint.activate([
            combinationAreaView.leadingAnchor.constraint(equalTo: productsCollectionView.trailingAnchor, constant: 10),
            combinationAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            combinationAreaView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 8),
            combinationAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Category
    @objc private func categoryTapped(_ sender: UIButton) {
        let category = CategoryType.allCases[sender.tag]
        selectedCategory = category
        filterProducts()
    }

    // MARK: - Data
    private func loadProducts() {
        allProducts = ProductManager.shared.loadProducts()
    }

    private func filterProducts() {
        if let selected = selectedCategory {
            filteredProducts = allProducts.filter { $0.category == selected }
        } else {
            filteredProducts = allProducts
        }
        productsCollectionView.reloadData()
    }

    private func loadImage(named: String) -> UIImage {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(named)
        return UIImage(contentsOfFile: fileURL.path) ?? UIImage(systemName: "photo")!
    }

    // Eski sabit yerleşim (tıkla‑ekle için hâlâ kullanıyoruz)
    private func frameForCategory(_ category: CategoryType) -> CGRect {
        let width: CGFloat = 100
        let height: CGFloat = 100

        switch category {
        case .ust:
            return CGRect(x: 10, y: 150, width: 130, height: 130)
        case .alt:
            return CGRect(x: 10, y: 260, width: 200, height: 200)
        case .ceket:
            return CGRect(x: 150, y: 150, width: 120, height: 120)
        case .elbise:
            return CGRect(x: 10, y: 150, width: 200, height: 200)
        case .ayakkabi:
            return CGRect(x: 100, y: 420, width: width, height: height)
        case .aksesuar:
            return CGRect(x: 200, y: 100, width: 50, height: 50)
        case .canta:
            return CGRect(x: 180, y: 260, width: 70, height: 70)
        }
    }

    // MARK: - Item içi etkileşimler
    @objc private func handleCombinationImageTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            imageView.removeFromSuperview()
            if let index = addedToCombination.firstIndex(of: imageView) {
                addedToCombination.remove(at: index)
            }
        }
    }

    private func addPanToImageView(_ imageView: UIImageView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleItemPan(_:)))
        imageView.addGestureRecognizer(pan)
    }

    @objc private func handleItemPan(_ gesture: UIPanGestureRecognizer) {
        guard let viewDragged = gesture.view as? UIImageView else { return }
        let translation = gesture.translation(in: combinationAreaView)

        switch gesture.state {
        case .changed:
            viewDragged.center = CGPoint(x: viewDragged.center.x + translation.x,
                                         y: viewDragged.center.y + translation.y)
            gesture.setTranslation(.zero, in: combinationAreaView)
        case .ended, .cancelled:
            // Sınırların içinde kal
            var frame = viewDragged.frame
            frame.origin.x = max(0, min(frame.origin.x, combinationAreaView.bounds.width - frame.width))
            frame.origin.y = max(0, min(frame.origin.y, combinationAreaView.bounds.height - frame.height))
            UIView.animate(withDuration: 0.15) { viewDragged.frame = frame }
        default: break
        }
    }

    // MARK: - Koleksiyondan Sürükle-Bırak (Uzun bas)
    @objc private func handleCollectionLongPress(_ gesture: UILongPressGestureRecognizer) {
        let locationInCollection = gesture.location(in: productsCollectionView)

        switch gesture.state {
        case .began:
            guard let indexPath = productsCollectionView.indexPathForItem(at: locationInCollection),
                  let cell = productsCollectionView.cellForItem(at: indexPath) as? ProductCell else { return }

            // Ürünün resmini al
            let product = filteredProducts[indexPath.item]
            draggingImageName = product.imageName
            let image = loadImage(named: product.imageName)

            // Önizleme imageView
            let preview = UIImageView(image: image)
            preview.contentMode = .scaleAspectFit
            preview.clipsToBounds = true
            let size: CGFloat = 120
            let startPoint = productsCollectionView.convert(cell.center, to: view)
            preview.frame = CGRect(x: startPoint.x - size/2, y: startPoint.y - size/2, width: size, height: size)
            preview.alpha = 0.9
            preview.layer.shadowColor = UIColor.black.cgColor
            preview.layer.shadowOpacity = 0.2
            preview.layer.shadowRadius = 6
            preview.layer.shadowOffset = CGSize(width: 0, height: 3)

            view.addSubview(preview)
            dragPreviewImageView = preview
            dragPreviewOriginalCenter = preview.center

        case .changed:
            guard let preview = dragPreviewImageView else { return }
            let locationInView = gesture.location(in: view)
            preview.center = locationInView

        case .ended, .cancelled:
            guard let preview = dragPreviewImageView else { return }
            let dropPointInView = gesture.location(in: view)

            // Bırakma noktası combinationAreaView içinde mi?
            let dropPointInCombination = view.convert(dropPointInView, to: combinationAreaView)
            if combinationAreaView.bounds.contains(dropPointInCombination) {
                // Kalıcı imageView'ı combinationAreaView içine ekle
                let finalImageView = UIImageView(image: preview.image)
                finalImageView.contentMode = .scaleAspectFit
                finalImageView.clipsToBounds = true
                finalImageView.isUserInteractionEnabled = true
                finalImageView.accessibilityIdentifier = draggingImageName

                // Başlangıç boyutu ve merkez, bıraktığın noktaya göre
                let width: CGFloat = 140
                let height: CGFloat = 140
                finalImageView.frame = CGRect(x: dropPointInCombination.x - width/2,
                                              y: dropPointInCombination.y - height/2,
                                              width: width,
                                              height: height)

                // Sınırların dışına taşmasın
                var frame = finalImageView.frame
                frame.origin.x = max(0, min(frame.origin.x, combinationAreaView.bounds.width - frame.width))
                frame.origin.y = max(0, min(frame.origin.y, combinationAreaView.bounds.height - frame.height))
                finalImageView.frame = frame

                // Etkileşimler
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCombinationImageTap(_:)))
                finalImageView.addGestureRecognizer(tapGesture)
                addPanToImageView(finalImageView)

                combinationAreaView.addSubview(finalImageView)
                addedToCombination.append(finalImageView)
            }

            // Önizlemeyi kaldır / state reset
            UIView.animate(withDuration: 0.2, animations: {
                preview.alpha = 0.0
            }, completion: { _ in
                preview.removeFromSuperview()
            })
            dragPreviewImageView = nil
            draggingImageName = nil

        default: break
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension ClosetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }

        let product = filteredProducts[indexPath.item]
        let image = loadImage(named: product.imageName)
        cell.configure(with: image)
        cell.delegate = self
        return cell
    }

    // Mevcut tıkla–ekle davranışı (korundu)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = filteredProducts[indexPath.item]
        let image = loadImage(named: product.imageName)

        let imageView = UIImageView(image: image)
        imageView.frame = frameForCategory(product.category)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.accessibilityIdentifier = product.imageName

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCombinationImageTap(_:)))
        imageView.addGestureRecognizer(tapGesture)
        addPanToImageView(imageView) // alan içinde sürüklenebilir

        combinationAreaView.addSubview(imageView)
        addedToCombination.append(imageView)
    }
}

// MARK: - Çöp kutusuna basınca silme
extension ClosetViewController: ProductCellDelegate {
    func didTapDelete(for cell: ProductCell) {
        guard let indexPath = productsCollectionView.indexPath(for: cell) else { return }
        let product = filteredProducts[indexPath.item]
        ProductManager.shared.deleteProduct(product)
        loadProducts()
        filterProducts()
    }

    @objc private func saveCombinationTapped() {
        let date = getTodayDate()

        // 1) combinationAreaView görüntüsünü al (eski uyumluluk için)
        let renderer = UIGraphicsImageRenderer(bounds: combinationAreaView.bounds)
        let combinationImage = renderer.image { ctx in
            combinationAreaView.layer.render(in: ctx.cgContext)
        }
        let imageName = "combination_\(UUID().uuidString).png"
        let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName)
        if let pngData = combinationImage.pngData() {
            try? pngData.write(to: imageURL)
        }

        // 2) Parçaları topla (yeni)
        let items: [CombinationItem] = combinationAreaView.subviews.compactMap { sv in
            guard let iv = sv as? UIImageView,
                  let name = iv.accessibilityIdentifier else { return nil }
            return CombinationItem(imageName: name, frame: iv.frame)
        }

        // 3) Kombin nesnesi oluştur (geri uyumlu)
        var combination = Combination(id: UUID(), date: date, imageNames: [imageName])
        combination.items = items

        // 4) Kaydet
        CombinationManager.shared.saveCombination(combination)

        let alert = UIAlertController(title: "Başarılı", message: "Kombin kaydedildi!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    private func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: Date())
    }
}

// MARK: - Saved Combination Helpers
private extension ClosetViewController {
    /// Kaydedilmiş kombin görselini tek resim olarak gösterir (eski kayıtlar)
    func placeSavedCombination(imageName: String) {
        let img = loadImage(named: imageName)
        let iv = UIImageView(image: img)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = false

        let inset: CGFloat = 12
        iv.frame = combinationAreaView.bounds.insetBy(dx: inset, dy: inset)
        iv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        combinationAreaView.addSubview(iv)
    }

    /// Yeni model ile gelen parçaları tek tek yerleştir
    func placeItems(_ items: [CombinationItem]) {
        // İstersen önce temizle:
        // combinationAreaView.subviews.forEach { $0.removeFromSuperview() }
        // addedToCombination.removeAll()

        for item in items {
            let img = loadImage(named: item.imageName)
            let iv = UIImageView(image: img)
            iv.frame = item.frame
            iv.contentMode = .scaleAspectFit
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true
            iv.accessibilityIdentifier = item.imageName

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCombinationImageTap(_:)))
            iv.addGestureRecognizer(tapGesture)
            addPanToImageView(iv)

            combinationAreaView.addSubview(iv)
            addedToCombination.append(iv)
        }
    }
}
