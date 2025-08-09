//
//  Combination.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

import Foundation
import CoreGraphics // CGRect için

struct Combination: Codable, Equatable {
    let id: UUID
    let date: String
    let imageNames: [String]
    var items: [CombinationItem]?  // eski kayıtlar için nil kalır
}

// Her bir yerleştirilen parça
struct CombinationItem: Codable, Equatable {
    let imageName: String   // Belgeler klasöründeki görsel adı
    let frame: CGRect       // combinationAreaView içindeki konumu/boyutu
}
