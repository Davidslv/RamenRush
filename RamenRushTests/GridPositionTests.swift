//
//  GridPositionTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct GridPositionTests {
    
    @Test func testValidPosition() {
        let position = GridPosition(3, 4)
        #expect(position.isValid())
        #expect(position.row == 3)
        #expect(position.column == 4)
    }
    
    @Test func testInvalidPositionNegative() {
        let position = GridPosition(-1, 4)
        #expect(!position.isValid())
    }
    
    @Test func testInvalidPositionTooLarge() {
        let position = GridPosition(8, 4)
        #expect(!position.isValid())
    }
    
    @Test func testAdjacentPositions() {
        let position = GridPosition(3, 3)
        let adjacent = position.adjacentPositions()
        
        #expect(adjacent.count == 4)
        #expect(adjacent.contains(GridPosition(2, 3))) // Up
        #expect(adjacent.contains(GridPosition(4, 3))) // Down
        #expect(adjacent.contains(GridPosition(3, 2))) // Left
        #expect(adjacent.contains(GridPosition(3, 4))) // Right
    }
    
    @Test func testHorizontalLine() {
        let position = GridPosition(2, 2)
        let line = position.horizontalLine(length: 4)
        
        #expect(line.count == 4)
        #expect(line[0] == GridPosition(2, 2))
        #expect(line[1] == GridPosition(2, 3))
        #expect(line[2] == GridPosition(2, 4))
        #expect(line[3] == GridPosition(2, 5))
    }
    
    @Test func testHorizontalLineBoundary() {
        let position = GridPosition(2, 6)
        let line = position.horizontalLine(length: 4)
        
        // Should return empty array if line would exceed grid
        #expect(line.count == 0)
    }
    
    @Test func testVerticalLine() {
        let position = GridPosition(2, 2)
        let line = position.verticalLine(length: 4)
        
        #expect(line.count == 4)
        #expect(line[0] == GridPosition(2, 2))
        #expect(line[1] == GridPosition(3, 2))
        #expect(line[2] == GridPosition(4, 2))
        #expect(line[3] == GridPosition(5, 2))
    }
    
    @Test func testVerticalLineBoundary() {
        let position = GridPosition(6, 2)
        let line = position.verticalLine(length: 4)
        
        // Should return empty array if line would exceed grid
        #expect(line.count == 0)
    }
    
    @Test func testHashable() {
        let pos1 = GridPosition(3, 4)
        let pos2 = GridPosition(3, 4)
        let pos3 = GridPosition(3, 5)
        
        #expect(pos1 == pos2)
        #expect(pos1 != pos3)
        
        var set = Set<GridPosition>()
        set.insert(pos1)
        set.insert(pos2)
        set.insert(pos3)
        
        #expect(set.count == 2) // pos1 and pos2 are equal
    }
}

