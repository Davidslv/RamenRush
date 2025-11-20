//
//  GameGridTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct GameGridTests {

    var grid: GameGrid

    init() {
        grid = GameGrid(size: 4)  // Use 4x4 grid like the actual game
    }

    @Test func testGridInitialization() {
        #expect(grid.size == 4)

        // Check all cells are empty initially
        for row in 0..<4 {
            for col in 0..<4 {
                let position = GridPosition(row, col)
                let cell = grid.cell(at: position)
                #expect(cell != nil)
                #expect(cell?.isEmpty == true)
            }
        }
    }

    @Test func testSetIngredient() {
        let position = GridPosition(3, 4)
        grid.setIngredient(.ramen, at: position)

        let cell = grid.cell(at: position)
        #expect(cell?.ingredient == .ramen)
        #expect(cell?.isEmpty == false)
    }

    @Test func testSetIngredientInvalidPosition() {
        let invalidPosition = GridPosition(10, 10)
        grid.setIngredient(.ramen, at: invalidPosition)

        // Should not crash, but also shouldn't set anything
        let cell = grid.cell(at: invalidPosition)
        #expect(cell == nil)
    }

    @Test func testClearCell() {
        let position = GridPosition(2, 3)
        grid.setIngredient(.chashu, at: position)
        #expect(grid.cell(at: position)?.isEmpty == false)

        grid.clearCell(at: position)
        #expect(grid.cell(at: position)?.isEmpty == true)
    }

    @Test func testSelectCell() {
        let position = GridPosition(1, 1)
        grid.selectCell(at: position)

        let cell = grid.cell(at: position)
        #expect(cell?.isSelected == true)
    }

    @Test func testDeselectAll() {
        grid.selectCell(at: GridPosition(0, 0))
        grid.selectCell(at: GridPosition(1, 1))
        grid.selectCell(at: GridPosition(2, 2))

        grid.deselectAll()

        for row in 0..<4 {
            for col in 0..<4 {
                let cell = grid.cell(at: GridPosition(row, col))
                #expect(cell?.isSelected == false)
            }
        }
    }

    @Test func testFindHorizontalMatches() {
        // Create a horizontal line of 4 ramen noodles
        grid.setIngredient(.ramen, at: GridPosition(2, 0))
        grid.setIngredient(.ramen, at: GridPosition(2, 1))
        grid.setIngredient(.ramen, at: GridPosition(2, 2))
        grid.setIngredient(.ramen, at: GridPosition(2, 3))

        let matches = grid.findHorizontalMatches()

        #expect(matches.count == 1)
        #expect(matches[0].ingredient == .ramen)
        #expect(matches[0].length == 4)
    }

    @Test func testFindHorizontalMatchesLonger() {
        // In a 4x4 grid, max horizontal length is 4
        // Create a horizontal line of 4 ramen noodles
        for col in 0..<4 {
            grid.setIngredient(.ramen, at: GridPosition(3, col))
        }

        let matches = grid.findHorizontalMatches()

        #expect(matches.count == 1)
        #expect(matches[0].length == 4)
    }

    @Test func testFindHorizontalMatchesMultiple() {
        // Create two separate horizontal matches in a 4x4 grid
        // First 2 columns: ramen, last 2 columns: chashu
        for col in 0..<2 {
            grid.setIngredient(.ramen, at: GridPosition(1, col))
        }
        for col in 2..<4 {
            grid.setIngredient(.chashu, at: GridPosition(1, col))
        }

        // No matches - need 4 for findHorizontalMatches default
        let matches = grid.findHorizontalMatches()
        #expect(matches.count == 0)  // No 4-long matches
        
        // But with minLength 2, should find both
        let shortMatches = grid.findHorizontalMatches(minLength: 2)
        #expect(shortMatches.count == 2)
    }

    @Test func testFindVerticalMatches() {
        // Create a vertical line of 4 ramen noodles
        grid.setIngredient(.ramen, at: GridPosition(0, 3))
        grid.setIngredient(.ramen, at: GridPosition(1, 3))
        grid.setIngredient(.ramen, at: GridPosition(2, 3))
        grid.setIngredient(.ramen, at: GridPosition(3, 3))

        let matches = grid.findVerticalMatches()

        #expect(matches.count == 1)
        #expect(matches[0].ingredient == .ramen)
        #expect(matches[0].length == 4)
    }

    @Test func testFindAllMatches() {
        // Create both horizontal and vertical matches
        for col in 0..<4 {
            grid.setIngredient(.ramen, at: GridPosition(0, col))
        }
        for row in 0..<4 {
            grid.setIngredient(.chashu, at: GridPosition(row, 5))
        }

        let matches = grid.findAllMatches()

        #expect(matches.count == 2)
    }

    @Test func testClearMatches() {
        // Create a match
        let matchPositions = [
            GridPosition(2, 0),
            GridPosition(2, 1),
            GridPosition(2, 2),
            GridPosition(2, 3)
        ]

        for pos in matchPositions {
            grid.setIngredient(.ramen, at: pos)
        }

        let match = LineMatch(positions: matchPositions, ingredient: .ramen)
        grid.clearMatches([match])

        // All positions should be empty
        for pos in matchPositions {
            #expect(grid.cell(at: pos)?.isEmpty == true)
        }
    }

    @Test func testFillEmptyCells() {
        let ingredients: [IngredientType] = [.ramen, .chashu, .softBoiledEgg]

        // Clear some cells
        grid.clearCell(at: GridPosition(0, 0))
        grid.clearCell(at: GridPosition(1, 1))
        grid.clearCell(at: GridPosition(2, 2))

        grid.fillEmptyCells(with: ingredients)

        // All cleared cells should now have ingredients
        for pos in [GridPosition(0, 0), GridPosition(1, 1), GridPosition(2, 2)] {
            let cell = grid.cell(at: pos)
            #expect(cell?.ingredient != nil)
            #expect(ingredients.contains(cell?.ingredient ?? .ramen))
        }
    }

    @Test func testPositionsWithIngredient() {
        grid.setIngredient(.ramen, at: GridPosition(0, 0))
        grid.setIngredient(.ramen, at: GridPosition(1, 1))
        grid.setIngredient(.chashu, at: GridPosition(2, 2))

        let ramenPositions = grid.positions(with: .ramen)

        #expect(ramenPositions.count == 2)
        #expect(ramenPositions.contains(GridPosition(0, 0)))
        #expect(ramenPositions.contains(GridPosition(1, 1)))
    }
    
    // MARK: - Gravity System Tests
    
    @Test func testInitializeUpcomingQueue() {
        let smallGrid = GameGrid(size: 4)
        let ingredients: [IngredientType] = [.ramen, .chashu, .softBoiledEgg, .greenOnions]
        
        smallGrid.initializeUpcomingQueue(with: ingredients, queueSize: 3)
        
        // Should have 4 columns (size of grid)
        #expect(smallGrid.upcomingIngredients.count == 4)
        
        // Each column should have 3 items in queue
        for col in 0..<4 {
            #expect(smallGrid.upcomingIngredients[col].count == 3)
        }
    }
    
    @Test func testPreviewIngredient() {
        let smallGrid = GameGrid(size: 4)
        let ingredients: [IngredientType] = [.ramen]
        
        smallGrid.initializeUpcomingQueue(with: ingredients, queueSize: 2)
        
        // Preview should return the first ingredient in queue
        let preview = smallGrid.previewIngredient(for: 0)
        #expect(preview == .ramen)
    }
    
    @Test func testApplyGravitySimple() {
        let smallGrid = GameGrid(size: 4)
        let ingredients: [IngredientType] = [.ramen, .chashu, .softBoiledEgg, .greenOnions]
        
        // Fill grid with known pattern
        // Column 0: ramen at rows 0, 1, 2, 3
        for row in 0..<4 {
            smallGrid.setIngredient(.ramen, at: GridPosition(row, 0))
        }
        
        // Clear bottom cell (row 3)
        smallGrid.clearCell(at: GridPosition(3, 0))
        
        // Initialize queue for refill
        smallGrid.initializeUpcomingQueue(with: ingredients, queueSize: 4)
        
        // Apply gravity
        let drops = smallGrid.applyGravity(with: ingredients)
        
        // Should have drops (ingredients shifting down)
        #expect(drops.count > 0)
        
        // Bottom cell should now have an ingredient
        let bottomCell = smallGrid.cell(at: GridPosition(3, 0))
        #expect(bottomCell?.ingredient != nil)
    }
    
    @Test func testApplyGravityMiddleClear() {
        let smallGrid = GameGrid(size: 4)
        let ingredients: [IngredientType] = [.chashu]
        
        // Fill column 0
        smallGrid.setIngredient(.ramen, at: GridPosition(0, 0))
        smallGrid.setIngredient(.chashu, at: GridPosition(1, 0))
        smallGrid.setIngredient(.tofu, at: GridPosition(2, 0))
        smallGrid.setIngredient(.nori, at: GridPosition(3, 0))
        
        // Clear middle cell (row 1)
        smallGrid.clearCell(at: GridPosition(1, 0))
        
        // Initialize queue
        smallGrid.initializeUpcomingQueue(with: ingredients, queueSize: 4)
        
        // Apply gravity
        _ = smallGrid.applyGravity(with: ingredients)
        
        // After gravity:
        // Row 0: should have new ingredient from queue (chashu)
        // Row 1: should have ramen (dropped from row 0)
        // Row 2: should have tofu (stayed)
        // Row 3: should have nori (stayed)
        
        #expect(smallGrid.cell(at: GridPosition(1, 0))?.ingredient == .ramen)
        #expect(smallGrid.cell(at: GridPosition(2, 0))?.ingredient == .tofu)
        #expect(smallGrid.cell(at: GridPosition(3, 0))?.ingredient == .nori)
    }
    
    @Test func testClearAndApplyGravity() {
        let smallGrid = GameGrid(size: 4)
        let ingredients: [IngredientType] = [.ramen]
        
        // Fill grid completely
        for row in 0..<4 {
            for col in 0..<4 {
                smallGrid.setIngredient(.chashu, at: GridPosition(row, col))
            }
        }
        
        // Create a match at bottom row
        let matchPositions = [
            GridPosition(3, 0),
            GridPosition(3, 1),
            GridPosition(3, 2),
            GridPosition(3, 3)
        ]
        let match = LineMatch(positions: matchPositions, ingredient: .chashu)
        
        // Initialize queue
        smallGrid.initializeUpcomingQueue(with: ingredients, queueSize: 4)
        
        // Clear and apply gravity
        let drops = smallGrid.clearAndApplyGravity([match], with: ingredients)
        
        // Should have drops for all 4 columns
        #expect(drops.count > 0)
        
        // Grid should be full again
        for row in 0..<4 {
            for col in 0..<4 {
                let cell = smallGrid.cell(at: GridPosition(row, col))
                #expect(cell?.ingredient != nil)
            }
        }
    }
    
    @Test func testIngredientDropProperties() {
        let drop = IngredientDrop(
            ingredient: .ramen,
            fromPosition: GridPosition(-1, 0),  // From preview
            toPosition: GridPosition(0, 0)
        )
        
        #expect(drop.dropDistance == 1)
        #expect(drop.isFromPreview == true)
        
        let normalDrop = IngredientDrop(
            ingredient: .chashu,
            fromPosition: GridPosition(1, 0),
            toPosition: GridPosition(3, 0)
        )
        
        #expect(normalDrop.dropDistance == 2)
        #expect(normalDrop.isFromPreview == false)
    }
}

