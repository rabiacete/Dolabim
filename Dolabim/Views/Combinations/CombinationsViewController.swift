import UIKit

class CombinationsViewController: UIViewController {

    private var combinations: [Combination] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 48) / 2, height: 250)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "Kombinlerim"
        setupCollectionView()
        loadCombinations()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CombinationCell.self, forCellWithReuseIdentifier: CombinationCell.identifier)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func loadCombinations() {
        combinations = CombinationManager.shared.loadCombinations()
        collectionView.reloadData()
    }
}

// MARK: - CollectionView DataSource & Delegate
extension CombinationsViewController: UICollectionViewDataSource, UICollectionViewDelegate, CombinationCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return combinations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CombinationCell.identifier, for: indexPath) as? CombinationCell else {
            return UICollectionViewCell()
        }

        let combination = combinations[indexPath.item]
        cell.configure(with: combination)
        cell.delegate = self
        cell.setEditing(true) // çöp kutusu hep görünür
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let combination = combinations[indexPath.item]

        // Full-screen preview açmak
      /*  let previewVC = CombinationPreviewViewController(combination: combination)
        present(previewVC, animated: true)

       */
        // Eğer Closet ekranına gitmek istiyorsan yukarıyı silip aşağıyı açarsın:
        
        let closetVC = ClosetViewController()
        closetVC.loadCombination(combination)   // instance method
        navigationController?.pushViewController(closetVC, animated: true)

    }

    func combinationCellDidTapDelete(_ cell: CombinationCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let combination = combinations[indexPath.item]

        let alert = UIAlertController(title: "Silinsin mi?",
                                      message: "Bu kombini kalıcı olarak sileceksin.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { _ in
            CombinationManager.shared.deleteCombination(combination)
            self.loadCombinations()
        })
        present(alert, animated: true)
    }
}
