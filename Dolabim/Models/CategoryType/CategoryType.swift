//
//  CategoryType.swift
//  Dolabim
//
//  Created by Rabia Çete on 8.08.2025.
//
enum CategoryType: String, CaseIterable, Codable {
    case ust = "Üst"
    case alt = "Alt"
    case ceket = "Ceket"
    case elbise = "Elbise"
    case ayakkabi = "Ayakkabı"
    case canta = "Çanta"
    case aksesuar = "Aksesuar"
    
    var iconName: String {
        switch self {
        case .ust: return "icon_top"
        case .alt: return "icon_bottom"
        case .ceket: return "icon_jacket"
        case .elbise: return "icon_dress"
        case .ayakkabi: return "icon_shoes"
        case .canta: return "icon_bag"
        case .aksesuar: return "icon_accessory"
        }
    }
}
