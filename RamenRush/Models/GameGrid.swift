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

    /// Fill empty cells with random ingredients from available pool (simple fill, no gravity)
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
    
    // MARK: - Gravity-Based Refill System
    
    /// Queue of upcoming ingredients for each column (preview system)
    @Published private(set) var upcomingIngredients: [[IngredientType]] = []
    
    /// Initialize the upcoming ingredients queue for preview
    func initializeUpcomingQueue(with availableIngredients: [IngredientType], queueSize: Int = 4) {
        guard !availableIngredients.isEmpty else { return }
        
        upcomingIngredients = []
        for _ in 0..<size {
            var columnQueue: [IngredientType] = []
            for _ in 0..<queueSize {
                columnQueue.append(availableIngredients.randomElement()!)
            }
            upcomingIngredients.append(columnQueue)
        }
    }
    
    /// Get the next preview ingredient for a column (what's coming from the top)
    func previewIngredient(for column: Int) -> IngredientType? {
        guard column >= 0 && column < upcomingIngredients.count,
              !upcomingIngredients[column].isEmpty else { return nil }
        return upcomingIngredients[column].first
    }
    
    /// Apply gravity: drop all ingredients down and fill from top with new ones
    /// Returns the drop animations needed (from position, to position)
    func applyGravity(with availableIngredients: [IngredientType]) -> [IngredientDrop] {
        guard !availableIngredients.isEmpty else { return [] }
        
        var drops: [IngredientDrop] = []
        
        // Process each column independently
        for col in 0..<size {
            // Step 1: Collect existing ingredients and their original rows (bottom to top)
            var existingIngredients: [(ingredient: IngredientType, originalRow: Int)] = []
            
            for row in (0..<size).reversed() {
                let position = GridPosition(row, col)
                if let cell = cell(at: position), let ingredient = cell.ingredient {
                    existingIngredients.append((ingredient, row))
                }
            }
            
            // existingIngredients is now [bottom, ..., top] with original row info
            // Reverse to get [top, ..., bottom] order
            existingIngredients.reverse()
            
            // Step 2: Calculate how many new ingredients we need
            let emptyCount = size - existingIngredients.count
            
            // Step 3: Get new ingredients from the queue
            var newIngredients: [IngredientType] = []
            for _ in 0..<emptyCount {
                if col < upcomingIngredients.count && !upcomingIngredients[col].isEmpty {
                    let ingredient = upcomingIngredients[col].removeFirst()
                    newIngredients.append(ingredient)
                    // Refill queue
                    upcomingIngredients[col].append(availableIngredients.randomElement()!)
                } else {
                    newIngredients.append(availableIngredients.randomElement()!)
                }
            }
            
            // Step 4: Build new column and track drops
            // New ingredients go at the top (rows 0 to emptyCount-1)
            // Existing ingredients fill the rest
            
            for row in 0..<size {
                let position = GridPosition(row, col)
                
                if row < emptyCount {
                    // New ingredient from preview
                    let ingredient = newIngredients[row]
                    let fromRow = row - emptyCount  // Negative = from above grid
                    
                    drops.append(IngredientDrop(
                        ingredient: ingredient,
                        fromPosition: GridPosition(fromRow, col),
                        toPosition: position
                    ))
                    
                    setIngredient(ingredient, at: position)
                } else {
                    // Existing ingredient that may have dropped
                    let existingIndex = row - emptyCount
                    let (ingredient, originalRow) = existingIngredients[existingIndex]
                    
                    if originalRow != row {
                        // This ingredient dropped
                        drops.append(IngredientDrop(
                            ingredient: ingredient,
                            fromPosition: GridPosition(originalRow, col),
                            toPosition: position
                        ))
                    }
                    
                    setIngredient(ingredient, at: position)
                }
            }
        }
        
        return drops
    }
    
    /// Clear matched positions and apply gravity in one operation
    func clearAndApplyGravity(
        _ matches: [LineMatch],
        with availableIngredients: [IngredientType]
    ) -> [IngredientDrop] {
        // First clear the matched cells
        clearMatches(matches)
        
        // Then apply gravity
        return applyGravity(with: availableIngredients)
    }
}

/// Represents an ingredient dropping from one position to another
struct IngredientDrop {
    let ingredient: IngredientType
    let fromPosition: GridPosition
    let toPosition: GridPosition
    
    /// Distance dropped (in grid cells)
    var dropDistance: Int {
        toPosition.row - fromPosition.row
    }
    
    /// Whether this ingredient came from above the grid (preview)
    var isFromPreview: Bool {
        fromPosition.row < 0
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

