//
//  UploadViewController.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class UploadViewController: UIViewController {

     let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo"))
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemGray5
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let selectPhotoButton = CustomButton(title: "Fotoğraf Seç", iconName: "photo")
    private let removeBackgroundButton = CustomButton(title: "Arka Planı Temizle", iconName: "wand.and.stars")
    private let saveToClosetButton = CustomButton(title: "Dolabıma Kaydet", iconName: "bookmark")

    private let viewModel = UploadViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBeigeBG
        title = "Fotoğraf Yükle"
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(selectPhotoButton)
        view.addSubview(removeBackgroundButton)
        view.addSubview(saveToClosetButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            selectPhotoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.widthAnchor.constraint(equalToConstant: 250),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 50),

            removeBackgroundButton.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 20),
            removeBackgroundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeBackgroundButton.widthAnchor.constraint(equalToConstant: 250),
            removeBackgroundButton.heightAnchor.constraint(equalToConstant: 50),

            saveToClosetButton.topAnchor.constraint(equalTo: removeBackgroundButton.bottomAnchor, constant: 20),
            saveToClosetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveToClosetButton.widthAnchor.constraint(equalToConstant: 250),
            saveToClosetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        selectPhotoButton.addTarget(self, action: #selector(didTapSelectPhoto), for: .touchUpInside)
        removeBackgroundButton.addTarget(self, action: #selector(didTapRemoveBackground), for: .touchUpInside)
        saveToClosetButton.addTarget(self, action: #selector(didTapSaveToCloset), for: .touchUpInside)
    }

    @objc private func didTapSelectPhoto() {
        viewModel.selectPhoto(from: self) { [weak self] selectedImage in
            self?.imageView.image = selectedImage
        }
    }

    @objc private func didTapRemoveBackground() {
        guard let currentImage = imageView.image else { return }
        viewModel.removeBackground(from: currentImage) { [weak self] newImage in
            self?.imageView.image = newImage
        }
    }

    @objc private func didTapSaveToCloset() {
        guard let image = imageView.image else { return }
        viewModel.saveToCloset(image: image, from: self)
    }
}
