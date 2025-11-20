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
    @Published var availableIngredients: [IngredientType] = []
    @Published var lastOrderStarsEarned: Int = 0

    let orderManager = OrderManager()
    private let grid: GameGrid

    init(grid: GameGrid) {
        self.grid = grid
        updateAvailableIngredients()
    }

    /// Update available ingredients based on current level
    /// Start with just 4 basic ingredients (like original has 4 pastries)
    func updateAvailableIngredients() {
        if currentLevel == 1 {
            // Start with 4 basic ingredients
            availableIngredients = [.ramen, .chashu, .softBoiledEgg, .greenOnions]
        } else {
            availableIngredients = ProgressionManager.unlockIngredients(forLevel: currentLevel)
        }
    }

    /// Start a new level
    func startLevel(_ level: Int) {
        currentLevel = level
        updateAvailableIngredients()
        // Generate 4 orders (like original)
        orderManager.generateOrders(availableIngredients: availableIngredients, count: 4)
        // Fill entire grid with random ingredients
        fillGridWithIngredients()
    }

    /// Fill the entire grid with random ingredients
    private func fillGridWithIngredients() {
        guard !availableIngredients.isEmpty else { return }

        // Clear and fill all cells
        for row in 0..<GameGrid.defaultSize {
            for col in 0..<GameGrid.defaultSize {
                let position = GridPosition(row, col)
                let randomIngredient = availableIngredients.randomElement()!
                grid.setIngredient(randomIngredient, at: position)
            }
        }
    }

    /// Process a match and check if it fulfills any order
    func processMatch(_ match: LineMatch) -> Bool {
        // Check if match fulfills any order
        if let fulfilledOrder = orderManager.fulfillOrder(with: match) {
            // Clear matched cells
            grid.clearMatches([match])

            // Fill empty cells
            grid.fillEmptyCells(with: availableIngredients)

            // Remove fulfilled order
            orderManager.removeOrder(fulfilledOrder)

            // Add new order if needed
            if orderManager.orders.count < 4 {
                let ingredient = availableIngredients.randomElement() ?? .ramen
                let quantity = Int.random(in: 1...3)
                orderManager.addOrder(SimpleOrder(ingredient: ingredient, quantity: quantity))
            }

            // Award star for completing order
            stars += 1
            lastOrderStarsEarned = 1

            // Reset after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.lastOrderStarsEarned = 0
            }

            return true
        }

        return false
    }

    /// Advance to next level
    func advanceLevel() {
        currentLevel += 1
        updateAvailableIngredients()
        orderManager.generateOrders(availableIngredients: availableIngredients, count: 4)
    }
}

