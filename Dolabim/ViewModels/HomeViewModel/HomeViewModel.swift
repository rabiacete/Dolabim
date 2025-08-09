//
//  HomeViewModel.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import UIKit

class HomeViewModel {
    func navigateToUpload(from viewController: UIViewController) {
        let uploadVC = UploadViewController()
        viewController.navigationController?.pushViewController(uploadVC, animated: true)
    }

    func navigateToCloset(from viewController: UIViewController) {
        let closetVC = ClosetViewController()
        viewController.navigationController?.pushViewController(closetVC, animated: true)
    }

    func navigateToCombinations(from viewController: UIViewController) {
        let combinationsVC = CombinationsViewController()
        viewController.navigationController?.pushViewController(combinationsVC, animated: true)
    }
}
