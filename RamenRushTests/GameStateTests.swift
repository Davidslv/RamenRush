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
        grid = GameGrid()
        gameState = GameState(grid: grid)
    }

    @Test func testInitialState() {
        #expect(gameState.currentLevel == 1)
        #expect(gameState.stars == 0)
        #expect(gameState.coins == 0)
        #expect(gameState.currentOrder == nil)
    }

    @Test func testStartLevel() {
        gameState.startLevel(1)

        #expect(gameState.currentLevel == 1)
        #expect(gameState.currentOrder != nil)
        #expect(!gameState.availableIngredients.isEmpty)

        // Grid should be filled
        var hasIngredients = false
        for row in 0..<8 {
            for col in 0..<8 {
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
        gameState.startLevel(0)
        let level0Ingredients = gameState.availableIngredients
        #expect(level0Ingredients.count == 5) // Starting ingredients

        gameState.startLevel(3)
        let level3Ingredients = gameState.availableIngredients
        #expect(level3Ingredients.count > level0Ingredients.count)
        #expect(level3Ingredients.contains(.udon))
    }

    @Test func testProcessMatches() {
        gameState.startLevel(1)

        // Create a match
        let matchPositions = [
            GridPosition(0, 0),
            GridPosition(0, 1),
            GridPosition(0, 2),
            GridPosition(0, 3)
        ]

        // Set ingredients in grid
        for pos in matchPositions {
            grid.setIngredient(.ramen, at: pos)
        }

        let match = LineMatch(positions: matchPositions, ingredient: .ramen)
        let initialStars = gameState.stars

        gameState.processMatches([match])

        // Matched cells should be cleared and refilled
        // Note: Order completion depends on order requirements
        // Stars might increase if order is fulfilled
    }

    @Test func testAdvanceLevel() {
        gameState.startLevel(1)
        let initialLevel = gameState.currentLevel

        gameState.advanceLevel()

        #expect(gameState.currentLevel == initialLevel + 1)
        #expect(gameState.currentOrder != nil)
    }

    @Test func testGenerateNewOrder() {
        gameState.startLevel(1)
        gameState.generateNewOrder()

        #expect(gameState.currentOrder != nil)
        #expect(!(gameState.currentOrder?.requiredIngredients.isEmpty ?? true))
    }
}
