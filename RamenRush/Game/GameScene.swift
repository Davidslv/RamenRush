//
//  GameScene.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SpriteKit
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class GameScene: SKScene {
    private let grid: GameGrid
    private let gameState: GameState
    private var gridNodes: [[SKSpriteNode]] = []
    private var previewNodes: [SKSpriteNode] = []  // Preview row above grid
    private var cursorNode: SKSpriteNode?
    private var cursorPosition: GridPosition = GridPosition(0, 0)
    private var isHorizontal: Bool = true

    // Grid configuration - 4x4 grid like original
    private let cellSize: CGFloat = 60
    private let gridSpacing: CGFloat = 4
    private let gridSize: Int = 4

    init(size: CGSize, grid: GameGrid, gameState: GameState) {
        self.grid = grid
        self.gameState = gameState
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupScene()
        setupPreviewRow()
        setupGrid()
        setupCursor()
        setupObservers()
    }

    private func setupScene() {
        backgroundColor = SKColor(hex: "#FFF8E7") // Cream Background
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func setupPreviewRow() {
        // Preview row shows half-visible ingredients coming from the top
        let totalGridWidth = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalGridHeight = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let startX = -totalGridWidth / 2 + cellSize / 2
        
        // Position preview row above the grid
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 220
        let gridCenterY = (topMargin - bottomMargin) / 2
        let gridTopY = gridCenterY + totalGridHeight / 2
        
        // Preview is positioned above the grid top row
        // Add full cell height + extra spacing to clear the top row completely
        let previewY = gridTopY + cellSize + gridSpacing + cellSize / 2
        
        previewNodes = []
        
        for col in 0..<gridSize {
            let x = startX + CGFloat(col) * (cellSize + gridSpacing)
            
            // Create preview cell (half visible)
            let node = SKSpriteNode(color: .white, size: CGSize(width: cellSize, height: cellSize / 2))
            node.position = CGPoint(x: x, y: previewY)
            node.name = "preview_\(col)"
            node.alpha = 0.6  // Semi-transparent to show it's a preview
            
            // Clip the bottom half (only show top half of ingredient)
            let cropNode = SKCropNode()
            let maskNode = SKSpriteNode(color: .white, size: CGSize(width: cellSize, height: cellSize / 2))
            maskNode.position = CGPoint(x: 0, y: cellSize / 4)
            cropNode.maskNode = maskNode
            
            // Add emoji label for preview
            let emojiLabel = SKLabelNode()
            emojiLabel.name = "preview_emoji"
            emojiLabel.fontSize = cellSize * 0.6
            emojiLabel.verticalAlignmentMode = .center
            emojiLabel.horizontalAlignmentMode = .center
            emojiLabel.position = CGPoint(x: 0, y: -cellSize / 4)  // Offset so only top shows
            emojiLabel.zPosition = 10
            node.addChild(emojiLabel)
            
            addChild(node)
            previewNodes.append(node)
        }
        
        updatePreviewDisplay()
    }
    
    private func updatePreviewDisplay() {
        let previews = gameState.getPreviewIngredients()
        
        for (col, node) in previewNodes.enumerated() {
            if let emojiLabel = node.childNode(withName: "preview_emoji") as? SKLabelNode {
                if col < previews.count, let ingredient = previews[col] {
                    emojiLabel.text = ingredient.emoji
                } else {
                    emojiLabel.text = ""
                }
            }
        }
    }

    private func setupGrid() {
        // Center the 4x4 grid on screen, leave room for orders at bottom
        // With anchorPoint at (0.5, 0.5), coordinates are relative to center
        // Y-axis: positive is UP, negative is DOWN
        let totalGridWidth = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalGridHeight = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing

        // Calculate starting positions (top-left corner of grid)
        let startX = -totalGridWidth / 2 + cellSize / 2

        // Position grid accounting for UI elements:
        // Top HUD: ~80 points, Bottom UI: ~220 points (orders + controls)
        // Available space: size.height - 300
        // Center the grid in the available space, shifted up slightly
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 220
        let availableHeight = size.height - topMargin - bottomMargin
        let gridCenterY = (topMargin - bottomMargin) / 2

        // startY is the TOP of the grid (row 0)
        let startY = gridCenterY + totalGridHeight / 2

        gridNodes = []

        for row in 0..<gridSize {
            var rowNodes: [SKSpriteNode] = []
            for col in 0..<gridSize {
                let x = startX + CGFloat(col) * (cellSize + gridSpacing)
                let y = startY - CGFloat(row) * (cellSize + gridSpacing)

                let node = createCellNode(at: GridPosition(row, col))
                node.position = CGPoint(x: x, y: y)
                addChild(node)
                rowNodes.append(node)
            }
            gridNodes.append(rowNodes)
        }

        updateGridDisplay()
    }

    private func createCellNode(at position: GridPosition) -> SKSpriteNode {
        // Create white background cell
        let node = SKSpriteNode(color: .white, size: CGSize(width: cellSize, height: cellSize))
        node.name = "cell_\(position.row)_\(position.column)"

        // Add border
        let border = SKShapeNode(rect: CGRect(x: -cellSize/2, y: -cellSize/2, width: cellSize, height: cellSize))
        border.strokeColor = SKColor(hex: "#5C4033") // Dark Wood
        border.lineWidth = 2
        border.fillColor = .clear
        node.addChild(border)

        // Create label node for emoji (will be updated in updateGridDisplay)
        let emojiLabel = SKLabelNode()
        emojiLabel.name = "emoji"
        emojiLabel.fontSize = cellSize * 0.6
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.horizontalAlignmentMode = .center
        emojiLabel.zPosition = 10
        node.addChild(emojiLabel)

        return node
    }

    private func setupCursor() {
        let cursorSize = cellSize + 4
        cursorNode = SKSpriteNode(color: .clear, size: CGSize(width: cursorSize, height: cursorSize))
        cursorNode?.zPosition = 100

        // Create cursor outline
        let outline = SKShapeNode(rect: CGRect(
            x: -cursorSize/2,
            y: -cursorSize/2,
            width: cursorSize,
            height: cursorSize
        ))
        outline.strokeColor = SKColor(hex: "#D32F2F") // Red Lantern
        outline.lineWidth = 3
        outline.fillColor = .clear
        cursorNode?.addChild(outline)

        updateCursorPosition()
        if let cursor = cursorNode {
            addChild(cursor)
        }
    }

    private func setupObservers() {
        // Observe grid changes
        // Note: In a real implementation, you'd use Combine or delegate pattern
        // For now, we'll update manually when needed
    }

    private func updateGridDisplay() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let position = GridPosition(row, col)
                guard let cell = grid.cell(at: position),
                      let node = gridNodes[safe: row]?[safe: col] else { continue }

                // Update emoji label
                if let emojiLabel = node.childNode(withName: "emoji") as? SKLabelNode {
                    if let ingredient = cell.ingredient {
                        emojiLabel.text = ingredient.emoji
                        emojiLabel.alpha = cell.isSelected ? 0.7 : 1.0
                    } else {
                        emojiLabel.text = ""
                    }
                }

                // Update cell background
                if cell.ingredient != nil {
                    node.color = SKColor.white
                    node.alpha = cell.isSelected ? 0.7 : 1.0
                } else {
                    node.color = SKColor(hex: "#F8F9FA") // Rice White
                    node.alpha = 1.0
                }
            }
        }
    }

    private func updateCursorPosition() {
        guard let cursor = cursorNode else { return }

        let totalGridWidth = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalGridHeight = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let startX = -totalGridWidth / 2 + cellSize / 2

        // Match the positioning from setupGrid()
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 220
        let gridCenterY = (topMargin - bottomMargin) / 2
        let startY = gridCenterY + totalGridHeight / 2

        // Position cursor based on orientation
        // For horizontal: center on the row, span all columns
        // For vertical: center on the column, span all rows
        let x: CGFloat
        let y: CGFloat
        
        if isHorizontal {
            // Center horizontally (middle of row)
            x = 0  // Center of grid
            y = startY - CGFloat(cursorPosition.row) * (cellSize + gridSpacing)
        } else {
            // Center vertically (middle of column)
            x = startX + CGFloat(cursorPosition.column) * (cellSize + gridSpacing)
            y = gridCenterY  // Center of grid
        }

        cursor.position = CGPoint(x: x, y: y)

        // Update cursor shape based on orientation
        updateCursorShape()
    }

    private func updateCursorShape() {
        guard let cursor = cursorNode else { return }
        cursor.removeAllChildren()

        let cursorSize = cellSize + 4
        let outline: SKShapeNode

        if isHorizontal {
            // Horizontal line (4 cells wide)
            let lineWidth = (cellSize + gridSpacing) * 4 - gridSpacing
            outline = SKShapeNode(rect: CGRect(
                x: -lineWidth/2,
                y: -cursorSize/2,
                width: lineWidth,
                height: cursorSize
            ))
        } else {
            // Vertical line (4 cells tall)
            let lineHeight = (cellSize + gridSpacing) * 4 - gridSpacing
            outline = SKShapeNode(rect: CGRect(
                x: -cursorSize/2,
                y: -lineHeight/2,
                width: cursorSize,
                height: lineHeight
            ))
        }

        outline.strokeColor = SKColor(hex: "#D32F2F") // Red Lantern
        outline.lineWidth = 3
        outline.fillColor = SKColor(hex: "#D32F2F").withAlphaComponent(0.2)
        cursor.addChild(outline)
    }

    // MARK: - Touch Handling

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if touch is on grid
        if let position = positionForLocation(location) {
            selectLine(at: position)
        }
    }
    #elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        if let position = positionForLocation(location) {
            selectLine(at: position)
        }
    }
    #endif

    private func positionForLocation(_ location: CGPoint) -> GridPosition? {
        let totalGridWidth = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalGridHeight = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let startX = -totalGridWidth / 2

        // Match the positioning from setupGrid()
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 220
        let gridCenterY = (topMargin - bottomMargin) / 2
        let startY = gridCenterY + totalGridHeight / 2

        let relativeX = location.x - startX
        let relativeY = startY - location.y

        let col = Int(relativeX / (cellSize + gridSpacing))
        let row = Int(relativeY / (cellSize + gridSpacing))

        let position = GridPosition(row, col)
        return position.isValid(for: gridSize) ? position : nil
    }

    private func selectLine(at position: GridPosition) {
        grid.deselectAll()

        // Get the full row or column based on orientation
        let positions: [GridPosition]
        if isHorizontal {
            // Select entire row
            positions = (0..<gridSize).map { GridPosition(position.row, $0) }
        } else {
            // Select entire column
            positions = (0..<gridSize).map { GridPosition($0, position.column) }
        }

        // Select all positions in the line for visual feedback
        for pos in positions {
            grid.selectCell(at: pos)
        }

        // Find contiguous runs within this line and try to match orders
        findAndProcessMatches(in: positions)

        updateGridDisplay()
    }
    
    /// Find contiguous runs of ingredients in a line and process matches
    private func findAndProcessMatches(in positions: [GridPosition]) {
        // Find all contiguous runs in this line
        let runs = findContiguousRuns(in: positions)
        
        // Try to find a run that matches an order
        // Prioritize runs that contain the cursor position (what the user clicked)
        var matchedRun: LineMatch?
        
        // First, try to find a matching run that contains the cursor position
        for run in runs {
            let containsCursor = run.positions.contains(cursorPosition)
            if containsCursor {
                if gameState.orderManager.fulfillOrder(with: run) != nil {
                    matchedRun = run
                    break
                }
            }
        }
        
        // If no run containing cursor matches, try any run
        if matchedRun == nil {
            for run in runs {
                if gameState.orderManager.fulfillOrder(with: run) != nil {
                    matchedRun = run
                    break
                }
            }
        }
        
        if let match = matchedRun {
            // Highlight only the matched portion
            grid.deselectAll()
            for pos in match.positions {
                grid.selectCell(at: pos)
            }
            updateGridDisplay()
            
            // Process the match
            if let result = gameState.processMatch(match) {
                // Animate the full sequence: match → drops → cascades
                animateMatchResult(result)
            } else {
                // Shouldn't happen since we checked fulfillOrder above
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.grid.deselectAll()
                    self.updateGridDisplay()
                }
            }
        } else {
            // No matching run found - show feedback and deselect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.grid.deselectAll()
                self.updateGridDisplay()
            }
        }
    }
    
    /// Find all contiguous runs of the same ingredient in a line
    private func findContiguousRuns(in positions: [GridPosition]) -> [LineMatch] {
        var runs: [LineMatch] = []
        var currentIngredient: IngredientType?
        var currentRun: [GridPosition] = []
        
        for pos in positions {
            guard let cell = grid.cell(at: pos),
                  let ingredient = cell.ingredient else {
                // Empty cell - end current run
                if !currentRun.isEmpty, let ing = currentIngredient {
                    runs.append(LineMatch(positions: currentRun, ingredient: ing))
                }
                currentRun = []
                currentIngredient = nil
                continue
            }
            
            if ingredient == currentIngredient {
                // Continue current run
                currentRun.append(pos)
            } else {
                // Different ingredient - save previous run and start new one
                if !currentRun.isEmpty, let ing = currentIngredient {
                    runs.append(LineMatch(positions: currentRun, ingredient: ing))
                }
                currentRun = [pos]
                currentIngredient = ingredient
            }
        }
        
        // Save final run
        if !currentRun.isEmpty, let ing = currentIngredient {
            runs.append(LineMatch(positions: currentRun, ingredient: ing))
        }
        
        return runs
    }

    private func animateMatchResult(_ result: MatchResult) {
        // Phase 1: Animate initial match clearing
        animateClearCells(result.clearedPositions) {
            // Phase 2: Animate initial drops
            self.animateDrops(result.initialDrops) {
                // Phase 3: Animate cascades sequentially
                self.animateCascades(result.cascades, index: 0)
            }
        }
    }
    
    private func animateClearCells(_ positions: [GridPosition], completion: @escaping () -> Void) {
        for position in positions {
            guard let node = gridNodes[safe: position.row]?[safe: position.column] else { continue }

            // Scale and fade animation, then reset
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let reset = SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.0),
                SKAction.fadeIn(withDuration: 0.0)
            ])

            let sequence = SKAction.sequence([scaleUp, fadeOut, reset])
            node.run(sequence)

            // Add particle effect
            addParticleEffect(at: node.position)
        }

        // Call completion after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
        }
    }
    
    private func animateCascades(_ cascades: [CascadeRound], index: Int) {
        guard index < cascades.count else {
            // All cascades complete - finalize
            grid.deselectAll()
            updateGridDisplay()
            updatePreviewDisplay()
            return
        }
        
        let cascade = cascades[index]
        
        // Show star earned effect
        showStarEarnedEffect(count: cascade.matches.count)
        
        // Animate cascade matches clearing
        var allPositions: [GridPosition] = []
        for match in cascade.matches {
            allPositions.append(contentsOf: match.positions)
        }
        
        // Highlight cascade matches with special color
        for pos in allPositions {
            if let node = gridNodes[safe: pos.row]?[safe: pos.column] {
                // Flash gold for cascade
                let flashGold = SKAction.colorize(with: SKColor(hex: "#FFB300"), colorBlendFactor: 0.7, duration: 0.1)
                let flashBack = SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                node.run(SKAction.sequence([flashGold, flashBack]))
            }
        }
        
        // Clear cascade cells
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animateClearCells(allPositions) {
                // Animate drops from this cascade
                self.animateDrops(cascade.drops) {
                    // Continue to next cascade
                    self.animateCascades(cascades, index: index + 1)
                }
            }
        }
    }
    
    private func showStarEarnedEffect(count: Int) {
        // Create star burst effect for each star earned
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                let star = SKLabelNode(text: "⭐")
                star.fontSize = 40
                star.position = CGPoint(x: 0, y: 0)  // Center of screen
                star.zPosition = 500
                
                // Animate star floating up and fading
                let moveUp = SKAction.moveBy(x: CGFloat.random(in: -50...50), y: 100, duration: 0.8)
                let fadeOut = SKAction.fadeOut(withDuration: 0.8)
                let scale = SKAction.scale(to: 1.5, duration: 0.8)
                let remove = SKAction.removeFromParent()
                
                let group = SKAction.group([moveUp, fadeOut, scale])
                let sequence = SKAction.sequence([group, remove])
                
                self.addChild(star)
                star.run(sequence)
            }
        }
    }

    private func animateDrops(_ drops: [IngredientDrop], completion: @escaping () -> Void) {
        let dropDuration: TimeInterval = 0.15
        
        // Update grid display first (this sets final positions)
        updateGridDisplay()
        updatePreviewDisplay()
        
        // Animate each drop
        for drop in drops {
            guard let node = gridNodes[safe: drop.toPosition.row]?[safe: drop.toPosition.column] else { continue }
            
            // Calculate visual drop distance
            let dropPixels = CGFloat(drop.dropDistance) * (cellSize + gridSpacing)
            
            // Start position (above final position)
            let finalPosition = node.position
            let startPosition = CGPoint(x: finalPosition.x, y: finalPosition.y + dropPixels)
            
            // Animate from start to final
            node.position = startPosition
            node.alpha = 1.0
            
            let moveDown = SKAction.move(to: finalPosition, duration: dropDuration * Double(max(1, drop.dropDistance)))
            moveDown.timingMode = .easeIn
            
            // Add bounce effect at the end
            let bounceUp = SKAction.moveBy(x: 0, y: 4, duration: 0.05)
            let bounceDown = SKAction.moveBy(x: 0, y: -4, duration: 0.05)
            
            let sequence = SKAction.sequence([moveDown, bounceUp, bounceDown])
            node.run(sequence)
        }
        
        // Call completion after longest drop animation
        let maxDropDistance = drops.map { $0.dropDistance }.max() ?? 1
        let totalDuration = dropDuration * Double(maxDropDistance) + 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            completion()
        }
    }

    private func addParticleEffect(at position: CGPoint) {
        // Create simple particle effect
        let particle = SKSpriteNode(color: SKColor(hex: "#FFB300"), size: CGSize(width: 8, height: 8))
        particle.position = position
        particle.zPosition = 200

        // Animate particle
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])

        addChild(particle)
        particle.run(sequence)
    }


    // MARK: - Input Handling

    func moveCursor(direction: CursorDirection) {
        var newPosition = cursorPosition

        switch direction {
        case .up:
            newPosition = GridPosition(max(0, cursorPosition.row - 1), cursorPosition.column)
        case .down:
            newPosition = GridPosition(min(gridSize - 1, cursorPosition.row + 1), cursorPosition.column)
        case .left:
            newPosition = GridPosition(cursorPosition.row, max(0, cursorPosition.column - 1))
        case .right:
            newPosition = GridPosition(cursorPosition.row, min(gridSize - 1, cursorPosition.column + 1))
        }

        cursorPosition = newPosition
        updateCursorPosition()
    }

    func rotateCursor() {
        isHorizontal.toggle()
        updateCursorPosition()  // Position changes based on orientation
    }

    func selectCurrentLine() {
        selectLine(at: cursorPosition)
    }
}

enum CursorDirection {
    case up, down, left, right
}

// MARK: - Array Safe Access Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - SKColor Extension
extension SKColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

