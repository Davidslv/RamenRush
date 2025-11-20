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
        grid = GameGrid()
    }
    
    @Test func testGridInitialization() {
        #expect(grid.size == 8)
        
        // Check all cells are empty initially
        for row in 0..<8 {
            for col in 0..<8 {
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
        
        for row in 0..<8 {
            for col in 0..<8 {
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
        // Create a horizontal line of 6 ramen noodles
        for col in 0..<6 {
            grid.setIngredient(.ramen, at: GridPosition(3, col))
        }
        
        let matches = grid.findHorizontalMatches()
        
        #expect(matches.count == 1)
        #expect(matches[0].length == 6)
    }
    
    @Test func testFindHorizontalMatchesMultiple() {
        // Create two separate horizontal matches
        for col in 0..<4 {
            grid.setIngredient(.ramen, at: GridPosition(1, col))
        }
        for col in 4..<8 {
            grid.setIngredient(.chashu, at: GridPosition(1, col))
        }
        
        let matches = grid.findHorizontalMatches()
        
        #expect(matches.count == 2)
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
        
        // All cells should now have ingredients
        for row in 0..<8 {
            for col in 0..<8 {
                let cell = grid.cell(at: GridPosition(row, col))
                #expect(cell?.ingredient != nil)
                #expect(ingredients.contains(cell?.ingredient ?? .ramen))
            }
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
}

