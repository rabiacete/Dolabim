// CombinationCell.swift
import UIKit

protocol CombinationCellDelegate: AnyObject {
    func combinationCellDidTapDelete(_ cell: CombinationCell)
}

class CombinationCell: UICollectionViewCell {
    static let identifier = "CombinationCell"

    weak var delegate: CombinationCellDelegate?

    private let imageView = UIImageView()
    private let dateLabel = UILabel()

    // küçük çöp butonu
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        b.tintColor = .systemRed
        b.backgroundColor = .white
        b.layer.cornerRadius = 12
        b.clipsToBounds = true
        b.isHidden = true      // sadece düzenle modunda görünsün
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        setupLayout()
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .boldSystemFont(ofSize: 14)
        dateLabel.textAlignment = .center

        contentView.addSubview(imageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85),

            dateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // sağ-alt köşeye pinle
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            deleteButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with combination: Combination) {
        if let firstImageName = combination.imageNames.first,
           let image = loadImage(named: firstImageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo.on.rectangle")
        }
        dateLabel.text = combination.date
    }


    func setEditing(_ editing: Bool) {
        deleteButton.isHidden = false // her zaman görünür
    }

    @objc private func didTapDelete() {
        delegate?.combinationCellDidTapDelete(self)
    }

    private func loadImage(named name: String) -> UIImage? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return UIImage(contentsOfFile: path.appendingPathComponent(name).path)
    }
}
