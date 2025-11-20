//
//  GridPosition.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Represents a position on the game grid
struct GridPosition: Hashable, Codable {
    let row: Int
    let column: Int

    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }

    /// Check if position is valid for an 8x8 grid
    func isValid(for gridSize: Int = 8) -> Bool {
        row >= 0 && row < gridSize && column >= 0 && column < gridSize
    }

    /// Get adjacent positions (up, down, left, right)
    func adjacentPositions() -> [GridPosition] {
        [
            GridPosition(row - 1, column), // Up
            GridPosition(row + 1, column), // Down
            GridPosition(row, column - 1), // Left
            GridPosition(row, column + 1)  // Right
        ]
    }

    /// Get all positions in a horizontal line starting from this position
    func horizontalLine(length: Int, gridSize: Int = 8) -> [GridPosition] {
        guard column + length <= gridSize else { return [] }
        return (0..<length).map { GridPosition(row, column + $0) }
    }

    /// Get all positions in a vertical line starting from this position
    func verticalLine(length: Int, gridSize: Int = 8) -> [GridPosition] {
        guard row + length <= gridSize else { return [] }
        return (0..<length).map { GridPosition(row + $0, column) }
    }
}

extension GridPosition: CustomStringConvertible {
    var description: String {
        "(\(row), \(column))"
    }
}

