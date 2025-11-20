//
//  GameGrid.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Manages the 4x4 game grid (matching original Pico-8 game)
class GameGrid: ObservableObject {
    static let defaultSize = 4

    @Published private(set) var cells: [[GridCell]]
    private(set) var size: Int

    init(size: Int = GameGrid.defaultSize) {
        self.size = size
        self.cells = Array(repeating: Array(repeating: GridCell(), count: size), count: size)
    }

    /// Get cell at position
    func cell(at position: GridPosition) -> GridCell? {
        guard position.isValid(for: size) else { return nil }
        return cells[position.row][position.column]
    }

    /// Set ingredient at position
    func setIngredient(_ ingredient: IngredientType, at position: GridPosition) {
        guard position.isValid(for: size) else { return }
        cells[position.row][position.column].setIngredient(ingredient)
    }

    /// Clear cell at position
    func clearCell(at position: GridPosition) {
        guard position.isValid(for: size) else { return }
        cells[position.row][position.column].clear()
    }

    /// Select cell at position
    func selectCell(at position: GridPosition) {
        guard position.isValid(for: size) else { return }
        cells[position.row][position.column].isSelected = true
    }

    /// Deselect cell at position
    func deselectCell(at position: GridPosition) {
        guard position.isValid(for: size) else { return }
        cells[position.row][position.column].isSelected = false
    }

    /// Deselect all cells
    func deselectAll() {
        for row in 0..<size {
            for col in 0..<size {
                cells[row][col].isSelected = false
            }
        }
    }

    /// Get all positions with a specific ingredient
    func positions(with ingredient: IngredientType) -> [GridPosition] {
        var positions: [GridPosition] = []
        for row in 0..<size {
            for col in 0..<size {
                if cells[row][col].ingredient == ingredient {
                    positions.append(GridPosition(row, col))
                }
            }
        }
        return positions
    }

    /// Check if a line of positions contains matching ingredients
    func checkLine(_ positions: [GridPosition], matches ingredient: IngredientType) -> Bool {
        positions.allSatisfy { pos in
            guard let cell = cell(at: pos) else { return false }
            return cell.ingredient == ingredient
        }
    }

    /// Find all horizontal lines of matching ingredients (length 4+)
    func findHorizontalMatches(minLength: Int = 4) -> [LineMatch] {
        var matches: [LineMatch] = []

        for row in 0..<size {
            var currentIngredient: IngredientType?
            var currentLength = 0
            var startColumn = 0

            for col in 0..<size {
                guard let cell = cell(at: GridPosition(row, col)),
                      let ingredient = cell.ingredient else {
                    // Reset on empty cell
                    if currentLength >= minLength, let ing = currentIngredient {
                        matches.append(LineMatch(
                            positions: (startColumn..<startColumn + currentLength).map { GridPosition(row, $0) },
                            ingredient: ing
                        ))
                    }
                    currentIngredient = nil
                    currentLength = 0
                    continue
                }

                if ingredient == currentIngredient {
                    currentLength += 1
                } else {
                    // Check if previous line was a match
                    if currentLength >= minLength, let ing = currentIngredient {
                        matches.append(LineMatch(
                            positions: (startColumn..<startColumn + currentLength).map { GridPosition(row, $0) },
                            ingredient: ing
                        ))
                    }
                    // Start new line
                    currentIngredient = ingredient
                    currentLength = 1
                    startColumn = col
                }
            }

            // Check line at end of row
            if currentLength >= minLength, let ing = currentIngredient {
                matches.append(LineMatch(
                    positions: (startColumn..<startColumn + currentLength).map { GridPosition(row, $0) },
                    ingredient: ing
                ))
            }
        }

        return matches
    }

    /// Find all vertical lines of matching ingredients (length 4+)
    func findVerticalMatches(minLength: Int = 4) -> [LineMatch] {
        var matches: [LineMatch] = []

        for col in 0..<size {
            var currentIngredient: IngredientType?
            var currentLength = 0
            var startRow = 0

            for row in 0..<size {
                guard let cell = cell(at: GridPosition(row, col)),
                      let ingredient = cell.ingredient else {
                    // Reset on empty cell
                    if currentLength >= minLength, let ing = currentIngredient {
                        matches.append(LineMatch(
                            positions: (startRow..<startRow + currentLength).map { GridPosition($0, col) },
                            ingredient: ing
                        ))
                    }
                    currentIngredient = nil
                    currentLength = 0
                    continue
                }

                if ingredient == currentIngredient {
                    currentLength += 1
                } else {
                    // Check if previous line was a match
                    if currentLength >= minLength, let ing = currentIngredient {
                        matches.append(LineMatch(
                            positions: (startRow..<startRow + currentLength).map { GridPosition($0, col) },
                            ingredient: ing
                        ))
                    }
                    // Start new line
                    currentIngredient = ingredient
                    currentLength = 1
                    startRow = row
                }
            }

            // Check line at end of column
            if currentLength >= minLength, let ing = currentIngredient {
                matches.append(LineMatch(
                    positions: (startRow..<startRow + currentLength).map { GridPosition($0, col) },
                    ingredient: ing
                ))
            }
        }

        return matches
    }

    /// Find all matches (horizontal and vertical)
    func findAllMatches(minLength: Int = 4) -> [LineMatch] {
        findHorizontalMatches(minLength: minLength) + findVerticalMatches(minLength: minLength)
    }

    /// Clear matched positions
    func clearMatches(_ matches: [LineMatch]) {
        for match in matches {
            for position in match.positions {
                clearCell(at: position)
            }
        }
    }

    /// Fill empty cells with random ingredients from available pool
    func fillEmptyCells(with availableIngredients: [IngredientType]) {
        guard !availableIngredients.isEmpty else { return }

        for row in 0..<size {
            for col in 0..<size {
                let position = GridPosition(row, col)
                if cell(at: position)?.isEmpty == true {
                    let randomIngredient = availableIngredients.randomElement()!
                    setIngredient(randomIngredient, at: position)
                }
            }
        }
    }
}

/// Represents a matched line of ingredients
struct LineMatch: Codable {
    let positions: [GridPosition]
    let ingredient: IngredientType

    var length: Int {
        positions.count
    }
}

