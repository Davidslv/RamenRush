//
//  GameState.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation
import Combine

/// Manages the overall game state
class GameState: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var stars: Int = 0
    @Published var coins: Int = 0
    @Published var currentOrder: Order?
    @Published var availableIngredients: [IngredientType] = []
    
    private let grid: GameGrid
    
    init(grid: GameGrid) {
        self.grid = grid
        updateAvailableIngredients()
    }
    
    /// Update available ingredients based on current level
    func updateAvailableIngredients() {
        availableIngredients = ProgressionManager.unlockIngredients(forLevel: currentLevel)
    }
    
    /// Start a new level
    func startLevel(_ level: Int) {
        currentLevel = level
        updateAvailableIngredients()
        generateNewOrder()
        // Fill grid with random ingredients
        grid.fillEmptyCells(with: availableIngredients)
    }
    
    /// Generate a new order
    func generateNewOrder() {
        let difficulty = determineDifficulty(for: currentLevel)
        currentOrder = OrderGenerator.generateOrder(
            level: currentLevel,
            availableIngredients: availableIngredients,
            difficulty: difficulty
        )
    }
    
    /// Determine order difficulty based on level
    private func determineDifficulty(for level: Int) -> OrderDifficulty {
        switch level {
        case 1...3:
            return .easy
        case 4...10:
            return .normal
        default:
            return .hard
        }
    }
    
    /// Process matches and check if order is completed
    func processMatches(_ matches: [LineMatch]) {
        guard let order = currentOrder else { return }
        
        // Clear matched cells
        grid.clearMatches(matches)
        
        // Fill empty cells
        grid.fillEmptyCells(with: availableIngredients)
        
        // Check if order is completed
        if order.canFulfill(with: matches) {
            completeOrder(order)
        }
    }
    
    /// Complete an order and award rewards
    private func completeOrder(_ order: Order) {
        stars += order.reward.stars
        if let coinsReward = order.reward.coins {
            coins += coinsReward
        }
        
        // Generate new order
        generateNewOrder()
    }
    
    /// Advance to next level
    func advanceLevel() {
        currentLevel += 1
        updateAvailableIngredients()
        generateNewOrder()
    }
}

