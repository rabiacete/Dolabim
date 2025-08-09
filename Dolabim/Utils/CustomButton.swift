//
//  CustomButton.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class CustomButton: UIButton {
    init(title: String, iconName: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setImage(UIImage(systemName: iconName), for: .normal)
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        setTitleColor(.label, for: .normal)
        layer.cornerRadius = 12
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        translatesAutoresizingMaskIntoConstraints = false
        imageView?.tintColor = .label
        contentHorizontalAlignment = .center
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
