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
        // Initialize the preview queue for upcoming ingredients
        grid.initializeUpcomingQueue(with: availableIngredients, queueSize: 4)
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
    
    /// Get preview ingredients for display (what's coming from top)
    func getPreviewIngredients() -> [IngredientType?] {
        return (0..<GameGrid.defaultSize).map { col in
            grid.previewIngredient(for: col)
        }
    }

    /// Process a match and check if it fulfills any order
    /// Returns animation data including initial drops and cascade information
    func processMatch(_ match: LineMatch) -> MatchResult? {
        // Check if match fulfills any order
        if let fulfilledOrder = orderManager.fulfillOrder(with: match) {
            // Clear matched cells and apply gravity
            let initialDrops = grid.clearAndApplyGravity([match], with: availableIngredients)

            // Remove fulfilled order
            orderManager.removeOrder(fulfilledOrder)

            // Add new order if needed
            if orderManager.orders.count < 4 {
                let ingredient = availableIngredients.randomElement() ?? .ramen
                let quantity = Int.random(in: 1...3)  // Orders are x1, x2, x3 only
                orderManager.addOrder(SimpleOrder(ingredient: ingredient, quantity: quantity))
            }

            // Check for cascade 4-in-a-rows (this awards stars)
            let cascades = collectCascades()
            
            // Calculate total stars earned
            let starsEarned = cascades.reduce(0) { $0 + $1.matches.count }
            stars += starsEarned
            lastOrderStarsEarned = starsEarned

            // Reset star display after animations
            if starsEarned > 0 {
                let totalAnimationTime = 0.5 + Double(cascades.count) * 0.6
                DispatchQueue.main.asyncAfter(deadline: .now() + totalAnimationTime) {
                    self.lastOrderStarsEarned = 0
                }
            }

            return MatchResult(
                clearedPositions: match.positions,
                initialDrops: initialDrops,
                cascades: cascades
            )
        }

        return nil
    }
    
    /// Collect all cascade information for animation
    /// Each cascade represents one round of 4-in-a-row matches
    private func collectCascades() -> [CascadeRound] {
        var cascades: [CascadeRound] = []
        
        // Keep checking until no more 4-in-a-rows
        while true {
            // Find all 4-in-a-row matches
            let matches = grid.findAllMatches(minLength: 4)
            
            if matches.isEmpty {
                break  // No more cascades
            }
            
            // Clear all matches and apply gravity
            let drops = grid.clearAndApplyGravity(matches, with: availableIngredients)
            
            cascades.append(CascadeRound(matches: matches, drops: drops))
        }
        
        return cascades
    }

    /// Advance to next level
    func advanceLevel() {
        currentLevel += 1
        updateAvailableIngredients()
        orderManager.generateOrders(availableIngredients: availableIngredients, count: 4)
    }
}

/// Result of processing a match, containing all animation data
struct MatchResult {
    let clearedPositions: [GridPosition]
    let initialDrops: [IngredientDrop]
    let cascades: [CascadeRound]
    
    var totalStarsEarned: Int {
        cascades.reduce(0) { $0 + $1.matches.count }
    }
}

/// One round of cascade matches
struct CascadeRound {
    let matches: [LineMatch]
    let drops: [IngredientDrop]
}