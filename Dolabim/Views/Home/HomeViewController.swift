//
//  HomeViewController.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - UI Elements

    private let uploadButton = CustomButton(title: "Fotoğraf Yükle", iconName: "camera")
    private let closetButton = CustomButton(title: "Dolabım", iconName: "hanger")
    private let combinationsButton = CustomButton(title: "Kombinlerim", iconName: "pants")

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "home_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Hafif overlay (okunabilirlik için)
    private let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - ViewModel
    private let viewModel = HomeViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        [uploadButton, closetButton, combinationsButton].forEach {
            $0.applyPastelGradientStyle()
            $0.addTapAnimation()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [uploadButton, closetButton, combinationsButton].forEach { $0.updateGradientFrameIfNeeded() }
    }

    // MARK: - Setup

    private func setupUI() {
        // Arka plan
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Overlay
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Butonlar
        view.addSubview(uploadButton)
        view.addSubview(closetButton)
        view.addSubview(combinationsButton)

        NSLayoutConstraint.activate([
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.bottomAnchor.constraint(equalTo: closetButton.topAnchor, constant: -20),
            uploadButton.widthAnchor.constraint(equalToConstant: 250),
            uploadButton.heightAnchor.constraint(equalToConstant: 55),

            closetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closetButton.bottomAnchor.constraint(equalTo: combinationsButton.topAnchor, constant: -20),
            closetButton.widthAnchor.constraint(equalToConstant: 250),
            closetButton.heightAnchor.constraint(equalToConstant: 55),

            combinationsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            combinationsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            combinationsButton.widthAnchor.constraint(equalToConstant: 250),
            combinationsButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    private func setupActions() {
        uploadButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        closetButton.addTarget(self, action: #selector(didTapCloset), for: .touchUpInside)
        combinationsButton.addTarget(self, action: #selector(didTapCombinations), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapUpload() {
        viewModel.navigateToUpload(from: self)
    }

    @objc private func didTapCloset() {
        viewModel.navigateToCloset(from: self)
    }

    @objc private func didTapCombinations() {
        viewModel.navigateToCombinations(from: self)
    }
}

// MARK: - UIButton Pastel Gradient Style

private let gradientLayerName = "modernGradientLayer"

extension UIButton {
    func applyPastelGradientStyle() {
        backgroundColor = .clear
        layer.cornerRadius = 25
        clipsToBounds = false
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)

        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        setTitleColor(.white, for: .normal)

        // İkon ayarları
        if let imageView = imageView {
            imageView.contentMode = .scaleAspectFit
        }
        semanticContentAttribute = .forceLeftToRight
        tintColor = .white
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 10)

        // Gradient (pastel bej tonları)
        let gradient = CAGradientLayer()
        gradient.name = gradientLayerName
        gradient.colors = [
            UIColor(red: 240/255, green: 228/255, blue: 215/255, alpha: 1).cgColor, // Açık bej
            UIColor(red: 223/255, green: 207/255, blue: 190/255, alpha: 1).cgColor  // Koyu bej
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.cornerRadius = 25
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)

        // Yumuşak shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
    }

    func updateGradientFrameIfNeeded() {
        guard let layers = layer.sublayers else { return }
        if let grad = layers.first(where: { $0.name == gradientLayerName }) as? CAGradientLayer {
            grad.frame = bounds
            grad.cornerRadius = layer.cornerRadius
        }
    }

    func addTapAnimation() {
        addTarget(self, action: #selector(_animateTap), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(_animateRelease), for: [.touchUpInside, .touchDragExit, .touchCancel])
    }

    @objc private func _animateTap() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func _animateRelease() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
