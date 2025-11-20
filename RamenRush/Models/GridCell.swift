//
//  GridCell.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Represents a single cell in the game grid
struct GridCell: Codable {
    var ingredient: IngredientType?
    var isSelected: Bool = false

    var isEmpty: Bool {
        ingredient == nil
    }

    mutating func clear() {
        ingredient = nil
        isSelected = false
    }

    mutating func setIngredient(_ ingredient: IngredientType) {
        self.ingredient = ingredient
    }
}

