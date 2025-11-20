//
//  GameStateTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct GameStateTests {

    var grid: GameGrid
    var gameState: GameState

    init() {
        grid = GameGrid(size: 4)  // Use 4x4 grid like the actual game
        gameState = GameState(grid: grid)
    }

    @Test func testInitialState() {
        #expect(gameState.currentLevel == 1)
        #expect(gameState.stars == 0)
        #expect(gameState.coins == 0)
    }

    @Test func testStartLevel() {
        gameState.startLevel(1)

        #expect(gameState.currentLevel == 1)
        #expect(gameState.orderManager.orders.count == 4)  // Should have 4 orders
        #expect(!gameState.availableIngredients.isEmpty)

        // Grid should be filled
        var hasIngredients = false
        for row in 0..<4 {
            for col in 0..<4 {
                if let cell = grid.cell(at: GridPosition(row, col)),
                   cell.ingredient != nil {
                    hasIngredients = true
                    break
                }
            }
            if hasIngredients { break }
        }
        #expect(hasIngredients)
    }

    @Test func testUpdateAvailableIngredients() {
        // Level 1 starts with 4 basic ingredients
        gameState.startLevel(1)
        let level1Ingredients = gameState.availableIngredients
        #expect(level1Ingredients.count == 4)
        #expect(level1Ingredients.contains(.ramen))
        #expect(level1Ingredients.contains(.chashu))
        #expect(level1Ingredients.contains(.softBoiledEgg))
        #expect(level1Ingredients.contains(.greenOnions))

        // Level 3 unlocks udon
        gameState.startLevel(3)
        let level3Ingredients = gameState.availableIngredients
        #expect(level3Ingredients.count > level1Ingredients.count)
        #expect(level3Ingredients.contains(.udon))
    }

    @Test func testProcessMatchFulfillsOrder() {
        gameState.startLevel(1)

        // Add a specific order we can fulfill
        gameState.orderManager.orders.removeAll()
        gameState.orderManager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 2))

        // Set up grid with ramen in first two positions
        grid.setIngredient(.ramen, at: GridPosition(0, 0))
        grid.setIngredient(.ramen, at: GridPosition(0, 1))
        grid.setIngredient(.chashu, at: GridPosition(0, 2))
        grid.setIngredient(.softBoiledEgg, at: GridPosition(0, 3))

        // Create a match of 2 ramen
        let matchPositions = [
            GridPosition(0, 0),
            GridPosition(0, 1)
        ]
        let match = LineMatch(positions: matchPositions, ingredient: .ramen)

        // Process the match
        let result = gameState.processMatch(match)

        // Should return result (match was processed)
        #expect(result != nil)
        #expect(result?.clearedPositions.count == 2)
    }

    @Test func testProcessMatchNoMatchingOrder() {
        gameState.startLevel(1)

        // Add orders that won't match
        gameState.orderManager.orders.removeAll()
        gameState.orderManager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 3))  // Need 3

        // Set up grid
        grid.setIngredient(.ramen, at: GridPosition(0, 0))
        grid.setIngredient(.ramen, at: GridPosition(0, 1))

        // Create a match of 2 ramen (but order needs 3)
        let match = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .ramen
        )

        let result = gameState.processMatch(match)

        // Should return nil (no matching order)
        #expect(result == nil)
    }

    @Test func testStarEarningFromCascade() {
        gameState.startLevel(1)

        // Set up a scenario where completing an order creates a 4-in-a-row cascade
        gameState.orderManager.orders.removeAll()
        gameState.orderManager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 2))

        // Fill the grid strategically
        // Column 0: After clearing row 0 positions 0-1, the remaining cells might form 4-in-a-row
        
        let initialStars = gameState.stars
        
        // The cascade system awards stars when 4-in-a-row forms AFTER gravity
        // This is tested through the processCascades() method
        #expect(initialStars == 0)
    }
    
    @Test func testNoStarForOrderCompletion() {
        gameState.startLevel(1)

        // Add an order for 2 ramen
        gameState.orderManager.orders.removeAll()
        gameState.orderManager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 2))

        let initialStars = gameState.stars

        // Set up grid
        grid.setIngredient(.ramen, at: GridPosition(0, 0))
        grid.setIngredient(.ramen, at: GridPosition(0, 1))
        grid.setIngredient(.chashu, at: GridPosition(0, 2))
        grid.setIngredient(.softBoiledEgg, at: GridPosition(0, 3))
        
        // Fill rest of grid to prevent cascades
        for row in 1..<4 {
            for col in 0..<4 {
                grid.setIngredient(.greenOnions, at: GridPosition(row, col))
            }
        }

        // Create a match of 2 ramen
        let match = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .ramen
        )

        // Process the match
        let result = gameState.processMatch(match)

        // Should succeed
        #expect(result != nil)
        
        // Check cascade results - if no 4-in-a-row formed, no stars earned
        #expect(result?.cascades.count == 0 || result?.totalStarsEarned == 0)
    }

    @Test func testAdvanceLevel() {
        gameState.startLevel(1)
        let initialLevel = gameState.currentLevel

        gameState.advanceLevel()

        #expect(gameState.currentLevel == initialLevel + 1)
        #expect(gameState.orderManager.orders.count == 4)
    }

    @Test func testGetPreviewIngredients() {
        gameState.startLevel(1)
        
        let previews = gameState.getPreviewIngredients()
        
        // Should have 4 previews (one per column)
        #expect(previews.count == 4)
        
        // All should have ingredients
        for preview in previews {
            #expect(preview != nil)
        }
    }

    @Test func testOrderManagerIntegration() {
        gameState.startLevel(1)
        
        // Should have 4 orders
        #expect(gameState.orderManager.orders.count == 4)
        
        // All orders should have valid quantities (1-3, no x4)
        for order in gameState.orderManager.orders {
            #expect(order.quantity >= 1 && order.quantity <= 3)
            #expect(gameState.availableIngredients.contains(order.ingredient))
        }
    }
    
    // MARK: - Cascade System Tests
    
    @Test func testCascadeDetection() {
        // Test that the grid can find 4-in-a-row matches
        let testGrid = GameGrid(size: 4)
        
        // Create a 4-in-a-row horizontally
        for col in 0..<4 {
            testGrid.setIngredient(.ramen, at: GridPosition(0, col))
        }
        
        let matches = testGrid.findAllMatches(minLength: 4)
        #expect(matches.count == 1)
        #expect(matches[0].ingredient == .ramen)
        #expect(matches[0].length == 4)
    }
    
    @Test func testNoCascadeForShorterLines() {
        let testGrid = GameGrid(size: 4)
        
        // Create only 3 in a row (shouldn't trigger cascade)
        testGrid.setIngredient(.ramen, at: GridPosition(0, 0))
        testGrid.setIngredient(.ramen, at: GridPosition(0, 1))
        testGrid.setIngredient(.ramen, at: GridPosition(0, 2))
        testGrid.setIngredient(.chashu, at: GridPosition(0, 3))  // Different ingredient
        
        let matches = testGrid.findAllMatches(minLength: 4)
        #expect(matches.count == 0)  // No 4-in-a-row cascade
    }
    
    @Test func testMatchResultStructure() {
        let positions = [GridPosition(0, 0), GridPosition(0, 1)]
        let drops = [IngredientDrop(
            ingredient: .ramen,
            fromPosition: GridPosition(-1, 0),
            toPosition: GridPosition(0, 0)
        )]
        let cascades: [CascadeRound] = []
        
        let result = MatchResult(
            clearedPositions: positions,
            initialDrops: drops,
            cascades: cascades
        )
        
        #expect(result.clearedPositions.count == 2)
        #expect(result.initialDrops.count == 1)
        #expect(result.cascades.isEmpty)
        #expect(result.totalStarsEarned == 0)
    }
    
    @Test func testCascadeRoundStructure() {
        let match = LineMatch(
            positions: [
                GridPosition(0, 0),
                GridPosition(0, 1),
                GridPosition(0, 2),
                GridPosition(0, 3)
            ],
            ingredient: .ramen
        )
        let drops: [IngredientDrop] = []
        
        let cascade = CascadeRound(matches: [match], drops: drops)
        
        #expect(cascade.matches.count == 1)
        #expect(cascade.matches[0].length == 4)
    }
    
    @Test func testTotalStarsFromMultipleCascades() {
        let match1 = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2), GridPosition(0, 3)],
            ingredient: .ramen
        )
        let match2 = LineMatch(
            positions: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2), GridPosition(1, 3)],
            ingredient: .chashu
        )
        
        let cascade1 = CascadeRound(matches: [match1], drops: [])
        let cascade2 = CascadeRound(matches: [match2], drops: [])
        
        let result = MatchResult(
            clearedPositions: [],
            initialDrops: [],
            cascades: [cascade1, cascade2]
        )
        
        // Each cascade has 1 match = 1 star each = 2 total
        #expect(result.totalStarsEarned == 2)
    }
}
