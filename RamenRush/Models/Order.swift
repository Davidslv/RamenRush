//
//  Order.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Represents a customer order
struct Order: Identifiable, Codable {
    let id: UUID
    let requiredIngredients: [IngredientRequirement]
    let reward: OrderReward
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        requiredIngredients: [IngredientRequirement],
        reward: OrderReward,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.requiredIngredients = requiredIngredients
        self.reward = reward
        self.isCompleted = isCompleted
    }
    
    /// Check if order can be fulfilled with given matches
    func canFulfill(with matches: [LineMatch]) -> Bool {
        var remainingRequirements = requiredIngredients
        
        for match in matches {
            if let index = remainingRequirements.firstIndex(where: { req in
                req.ingredient == match.ingredient && req.quantity > 0
            }) {
                remainingRequirements[index].quantity -= match.length
                if remainingRequirements[index].quantity <= 0 {
                    remainingRequirements.remove(at: index)
                }
            }
        }
        
        return remainingRequirements.isEmpty || 
               remainingRequirements.allSatisfy { $0.quantity <= 0 }
    }
    
    /// Calculate completion progress (0.0 to 1.0)
    func completionProgress(with matches: [LineMatch]) -> Double {
        var totalNeeded = requiredIngredients.reduce(0) { $0 + $1.quantity }
        var totalMatched = 0
        
        var remainingRequirements = requiredIngredients
        
        for match in matches {
            if let index = remainingRequirements.firstIndex(where: { req in
                req.ingredient == match.ingredient && req.quantity > 0
            }) {
                let matched = min(match.length, remainingRequirements[index].quantity)
                totalMatched += matched
                remainingRequirements[index].quantity -= matched
            }
        }
        
        guard totalNeeded > 0 else { return 1.0 }
        return min(1.0, Double(totalMatched) / Double(totalNeeded))
    }
}

/// Represents a requirement for a specific ingredient quantity
struct IngredientRequirement: Codable {
    let ingredient: IngredientType
    var quantity: Int
    
    init(ingredient: IngredientType, quantity: Int) {
        self.ingredient = ingredient
        self.quantity = quantity
    }
}

/// Represents rewards for completing an order
struct OrderReward: Codable {
    let stars: Int
    let coins: Int?
    
    init(stars: Int, coins: Int? = nil) {
        self.stars = stars
        self.coins = coins
    }
}

/// Order generator for creating random orders
struct OrderGenerator {
    /// Generate a random order based on level and available ingredients
    static func generateOrder(
        level: Int,
        availableIngredients: [IngredientType],
        difficulty: OrderDifficulty = .normal
    ) -> Order {
        let unlockedIngredients = ProgressionManager.unlockIngredients(forLevel: level)
        let pool = availableIngredients.isEmpty ? unlockedIngredients : availableIngredients
        
        guard !pool.isEmpty else {
            // Fallback order
            return Order(
                requiredIngredients: [
                    IngredientRequirement(ingredient: .ramen, quantity: 4)
                ],
                reward: OrderReward(stars: 1)
            )
        }
        
        // Determine number of ingredients based on difficulty
        let ingredientCount: Int
        switch difficulty {
        case .easy:
            ingredientCount = 1
        case .normal:
            ingredientCount = Int.random(in: 1...2)
        case .hard:
            ingredientCount = Int.random(in: 2...3)
        }
        
        // Select random ingredients
        let selectedIngredients = Array(pool.shuffled().prefix(ingredientCount))
        let requirements = selectedIngredients.map { ingredient in
            IngredientRequirement(
                ingredient: ingredient,
                quantity: Int.random(in: 4...8) // Match 4-8 cells
            )
        }
        
        // Calculate reward based on difficulty
        let stars = difficulty.baseStars
        let coins = difficulty.baseCoins
        
        return Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: stars, coins: coins)
        )
    }
}

enum OrderDifficulty {
    case easy, normal, hard
    
    var baseStars: Int {
        switch self {
        case .easy: return 1
        case .normal: return 2
        case .hard: return 3
        }
    }
    
    var baseCoins: Int? {
        switch self {
        case .easy: return nil
        case .normal: return 10
        case .hard: return 25
        }
    }
}

