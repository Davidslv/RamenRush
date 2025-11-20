//
//  IngredientType.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Ingredient Category
enum IngredientCategory: String, Codable {
    case noodles, proteins, vegetables, bowls
}

// MARK: - Ingredient Type
enum IngredientType: String, Codable, CaseIterable, Identifiable {
    // Noodles
    case ramen, udon, soba, riceNoodles
    
    // Proteins
    case chashu, softBoiledEgg, tofu, tempuraShrimp
    
    // Vegetables
    case greenOnions, nori, bambooShoots, bokChoy
    
    // Bowls (special - these are the "containers")
    case ramenBowl, donburiBowl, bentoBox, sushiPlate
    
    var id: String { rawValue }
    
    var category: IngredientCategory {
        switch self {
        case .ramen, .udon, .soba, .riceNoodles:
            return .noodles
        case .chashu, .softBoiledEgg, .tofu, .tempuraShrimp:
            return .proteins
        case .greenOnions, .nori, .bambooShoots, .bokChoy:
            return .vegetables
        case .ramenBowl, .donburiBowl, .bentoBox, .sushiPlate:
            return .bowls
        }
    }
    
    var unlockLevel: Int {
        switch self {
        case .ramen, .chashu, .softBoiledEgg, .greenOnions, .ramenBowl:
            return 0  // Starting items
        case .udon:
            return 3
        case .tofu:
            return 4
        case .nori:
            return 5
        case .soba:
            return 6
        case .tempuraShrimp:
            return 7
        case .bambooShoots:
            return 8
        case .riceNoodles:
            return 9
        case .bokChoy:
            return 10
        case .donburiBowl:
            return 11
        case .bentoBox:
            return 13
        case .sushiPlate:
            return 15
        }
    }
    
    var displayName: String {
        switch self {
        case .ramen: return "Ramen"
        case .udon: return "Udon"
        case .soba: return "Soba"
        case .riceNoodles: return "Rice Noodles"
        case .chashu: return "Chashu Pork"
        case .softBoiledEgg: return "Soft-Boiled Egg"
        case .tofu: return "Tofu"
        case .tempuraShrimp: return "Tempura Shrimp"
        case .greenOnions: return "Green Onions"
        case .nori: return "Nori"
        case .bambooShoots: return "Bamboo Shoots"
        case .bokChoy: return "Bok Choy"
        case .ramenBowl: return "Ramen Bowl"
        case .donburiBowl: return "Donburi Bowl"
        case .bentoBox: return "Bento Box"
        case .sushiPlate: return "Sushi Plate"
        }
    }
    
    /// Placeholder color for rendering until sprites are ready
    var placeholderColor: Color {
        switch self {
        // Noodles
        case .ramen: return Color(hex: "#FFD93D") // Ramen Yellow
        case .udon: return Color(hex: "#FFFEF7") // Udon White
        case .soba: return Color(hex: "#A67C52") // Soba Brown
        case .riceNoodles: return Color(hex: "#FFEFD5") // Rice Noodle
        
        // Proteins
        case .chashu: return Color(hex: "#E8B4A4") // Pork Pink
        case .softBoiledEgg: return Color(hex: "#FFB800") // Egg Yolk
        case .tofu: return Color(hex: "#F5E6D3") // Tofu Beige
        case .tempuraShrimp: return Color(hex: "#FF6B35") // Shrimp Orange
        
        // Vegetables
        case .greenOnions: return Color(hex: "#A8E6A1") // Green Onion Light
        case .nori: return Color(hex: "#1A1A1A") // Nori Black
        case .bambooShoots: return Color(hex: "#E8DCA0") // Bamboo Yellow
        case .bokChoy: return Color(hex: "#7CB342") // Bok Choy Green
        
        // Bowls
        case .ramenBowl: return Color(hex: "#FFFFFF") // White
        case .donburiBowl: return Color(hex: "#1976D2") // Blue
        case .bentoBox: return Color(hex: "#8B4513") // Dark Brown
        case .sushiPlate: return Color(hex: "#FFFFFF") // White
        }
    }
    
    /// Check if ingredient is unlocked at given level
    func isUnlocked(at level: Int) -> Bool {
        unlockLevel <= level
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

