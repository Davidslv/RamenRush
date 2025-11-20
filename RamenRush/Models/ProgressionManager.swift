//
//  ProgressionManager.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Manages game progression and ingredient unlocks
struct ProgressionManager {
    /// Get all ingredients unlocked at given level
    static func unlockIngredients(forLevel level: Int) -> [IngredientType] {
        IngredientType.allCases.filter { 
            $0.unlockLevel <= level 
        }
    }
    
    /// Get the next ingredient that will be unlocked
    static func nextUnlock(currentLevel: Int) -> IngredientType? {
        IngredientType.allCases
            .filter { $0.unlockLevel > currentLevel }
            .min { $0.unlockLevel < $1.unlockLevel }
    }
    
    /// Get progress information for next unlock
    static func progressToNextUnlock(
        currentLevel: Int
    ) -> (current: Int, needed: Int)? {
        guard let next = nextUnlock(currentLevel: currentLevel) else {
            return nil
        }
        return (currentLevel, next.unlockLevel)
    }
    
    /// Check if an ingredient is unlocked at current level
    static func isUnlocked(_ ingredient: IngredientType, at level: Int) -> Bool {
        ingredient.unlockLevel <= level
    }
    
    /// Get all unlocked ingredients by category
    static func unlockedIngredientsByCategory(
        at level: Int
    ) -> [IngredientCategory: [IngredientType]] {
        let unlocked = unlockIngredients(forLevel: level)
        return Dictionary(grouping: unlocked) { $0.category }
    }
}

