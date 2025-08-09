//
//  Category.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//

enum Category: String, CaseIterable {
    case ust = "Üst"
    case alt = "Alt"
    case ceket = "Ceket"
    case elbise = "Elbise"
    case ayakkabi = "Ayakkabı"
    case canta = "Çanta"
    case aksesuar = "Aksesuar"
    
    var iconName: String {
        switch self {
        case .ust: return "tshirt"
        case .alt: return "figure.walk"
        case .ceket: return "suitcase"
        case .elbise: return "figure.dress.line.vertical.figure"
        case .ayakkabi: return "shoeprints.fill"
        case .canta: return "bag.fill"
        case .aksesuar: return "eyeglasses"
        }
    }
}
