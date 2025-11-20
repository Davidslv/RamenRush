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
        setupGrid()
        setupCursor()
        setupObservers()
    }

    private func setupScene() {
        backgroundColor = SKColor(hex: "#FFF8E7") // Cream Background
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    private func setupGrid() {
        // Center the 4x4 grid on screen, leave room for orders at bottom
        // With anchorPoint at (0.5, 0.5), coordinates are relative to center
        let totalGridWidth = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let startX = -totalGridWidth / 2 + cellSize / 2
        // Position grid in upper-center portion (negative Y is up from center)
        // Move it higher to be above order cards
        let startY = -size.height * 0.25 + cellSize / 2

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
        let startX = -totalGridWidth / 2 + cellSize / 2
        let startY = totalGridWidth / 2 - cellSize / 2

        let x = startX + CGFloat(cursorPosition.column) * (cellSize + gridSpacing)
        let y = startY - CGFloat(cursorPosition.row) * (cellSize + gridSpacing)

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
        let startX = -totalGridWidth / 2
        let startY = -size.height * 0.15 + totalGridWidth / 2

        let relativeX = location.x - startX
        let relativeY = startY - location.y

        let col = Int(relativeX / (cellSize + gridSpacing))
        let row = Int(relativeY / (cellSize + gridSpacing))

        let position = GridPosition(row, col)
        return position.isValid(for: gridSize) ? position : nil
    }

    private func selectLine(at position: GridPosition) {
        grid.deselectAll()

        let positions: [GridPosition]
        if isHorizontal {
            positions = position.horizontalLine(length: 4, gridSize: gridSize)
        } else {
            positions = position.verticalLine(length: 4, gridSize: gridSize)
        }

        // Select all positions in line
        for pos in positions {
            grid.selectCell(at: pos)
        }

        // Check for matches
        checkMatches(at: positions)

        updateGridDisplay()
    }

    private func checkMatches(at positions: [GridPosition]) {
        guard positions.count == 4,
              let firstCell = grid.cell(at: positions[0]),
              let ingredient = firstCell.ingredient else {
            // Deselect if invalid selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.grid.deselectAll()
                self.updateGridDisplay()
            }
            return
        }

        // Check if all positions have the same ingredient
        let allMatch = positions.allSatisfy { pos in
            grid.cell(at: pos)?.ingredient == ingredient
        }

        if allMatch {
            // Create a match (always length 4 for 4x4 grid)
            let match = LineMatch(positions: positions, ingredient: ingredient)

            // Check if this match fulfills any order
            if gameState.processMatch(match) {
                // Animate match
                animateMatch(positions)
            } else {
                // Match doesn't fulfill any order - show error feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.grid.deselectAll()
                    self.updateGridDisplay()
                }
            }
        } else {
            // Deselect after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.grid.deselectAll()
                self.updateGridDisplay()
            }
        }
    }

    private func animateMatch(_ positions: [GridPosition]) {
        // Enhanced animation with particles
        for position in positions {
            guard let node = gridNodes[safe: position.row]?[safe: position.column] else { continue }

            // Scale and fade animation
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)

            let sequence = SKAction.sequence([scaleUp, fadeOut, scaleDown, fadeIn])
            node.run(sequence)

            // Add particle effect
            addParticleEffect(at: node.position)
        }

        // Update grid after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.grid.deselectAll()
            self.updateGridDisplay()
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
        updateCursorShape()
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

