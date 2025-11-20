# 🍜 Ramen Rush - Technical Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [How to Play](#how-to-play)
3. [Architecture](#architecture)
4. [Core Systems](#core-systems)
5. [File Structure](#file-structure)
6. [Data Models](#data-models)
7. [Game Flow](#game-flow)
8. [Key Algorithms](#key-algorithms)
9. [UI/UX Components](#uiux-components)
10. [Testing](#testing)
11. [Known Issues & Bugs](#known-issues--bugs)
12. [Future Improvements](#future-improvements)
13. [Development Setup](#development-setup)
14. [Coding Conventions](#coding-conventions)

---

## Project Overview

### What is Ramen Rush?

Ramen Rush is a cozy puzzle game where players help Chef Hiro serve ramen by matching lines of ingredients to fulfill customer orders. It's inspired by classic match-line puzzle games with a Japanese food theme.

### Technical Stack

- **Platform**: iOS 18.5+
- **Language**: Swift 5.0+
- **Frameworks**: 
  - SpriteKit (game rendering)
  - SwiftUI (UI wrapper)
  - Combine (reactive state management)
- **Architecture**: MVVM-inspired with ObservableObject
- **Testing**: Swift Testing framework

### Game Identity

- **Genre**: Puzzle / Match-Line
- **Price**: $2.99 (Premium, no ads)
- **Rating**: 4+ (Family-friendly)
- **Target Audience**: Casual puzzle fans, families, food enthusiasts

---

## How to Play

### Objective

Complete customer orders by selecting lines of matching ingredients on a 4×4 grid.

### Basic Mechanics

1. **View Orders**: 4 order cards at the bottom show what customers want (e.g., 🍜x2 = 2 ramen)

2. **Select a Line**: 
   - Tap on the grid to select a row (horizontal) or column (vertical)
   - Use the rotate button (⟳) to switch between horizontal/vertical

3. **Match Orders**:
   - The game finds contiguous runs of the same ingredient in your selected line
   - If a run matches an order exactly (same ingredient + quantity), it's cleared
   - Example: Order 🍜x2 needs exactly 2 ramen in a row

4. **Gravity System**:
   - Cleared cells disappear
   - Remaining ingredients drop down
   - New ingredients enter from the top (preview row shows what's coming)

5. **Earn Stars (Cascade System)**:
   - After gravity, if 4-in-a-row forms anywhere on the grid, you earn a ⭐
   - Those 4 cells are automatically cleared
   - Gravity applies again (can chain multiple cascades)

6. **Win/Lose**:
   - Win: Complete all orders
   - Lose: Get stuck with no valid moves and no stars for power-ups

### Order Types

| Order | Meaning | Difficulty |
|-------|---------|------------|
| 🍜x1 | 1 ingredient | Easy |
| 🍜x2 | 2 in a line | Medium |
| 🍜x3 | 3 in a line | Hard |

### Controls

- **Touch**: Tap grid cell to select that row/column
- **Arrow Buttons**: Move cursor (↑↓←→)
- **Rotate Button**: Toggle horizontal/vertical (⟳)
- **Pause**: Top-right pause button (⏸)

---

## Architecture

### High-Level Architecture

```
┌─────────────────┐
│   SwiftUI       │  ← App entry, UI wrapper
│   (GameView)    │
└────────┬────────┘
         │
┌────────▼────────┐
│   SpriteKit     │  ← Game rendering, touch handling
│   (GameScene)   │
└────────┬────────┘
         │
┌────────▼────────┐
│   Game Logic    │  ← State management, rules
│   (GameState)   │
└────────┬────────┘
         │
┌────────▼────────┐
│   Data Models   │  ← Grid, Orders, Ingredients
│   (GameGrid)    │
└─────────────────┘
```

### Design Patterns

1. **ObservableObject**: GameState publishes changes to UI
2. **Value Types**: Structs for immutable data (GridPosition, LineMatch, etc.)
3. **Delegation**: GameScene delegates game logic to GameState
4. **Composition**: GameState composes GameGrid and OrderManager

### Data Flow

```
User Input → GameScene → GameState → GameGrid
                ↓              ↓
           Animation      State Update
                ↓              ↓
            Display    ←   @Published
```

---

## Core Systems

### 1. Grid System

**File**: `GameGrid.swift`

The game uses a 4×4 grid where each cell contains an ingredient.

```swift
class GameGrid: ObservableObject {
    static let defaultSize = 4
    @Published private(set) var cells: [[GridCell]]
    @Published private(set) var upcomingIngredients: [[IngredientType]]
}
```

**Key Operations**:
- `cell(at:)` - Get cell at position
- `setIngredient(_:at:)` - Place ingredient
- `clearCell(at:)` - Remove ingredient
- `findAllMatches(minLength:)` - Find 4-in-a-row patterns

### 2. Gravity System

**File**: `GameGrid.swift` → `applyGravity(with:)`

When cells are cleared:
1. Collect remaining ingredients per column (with original positions)
2. Calculate empty count
3. Get new ingredients from preview queue
4. Rebuild column: new at top, existing below
5. Track drops for animation

```swift
func applyGravity(with availableIngredients: [IngredientType]) -> [IngredientDrop]
```

### 3. Order System

**Files**: `SimpleOrder.swift`, `OrderManager`

Orders are simple: ingredient + quantity (x1, x2, x3)

```swift
struct SimpleOrder {
    let ingredient: IngredientType
    let quantity: Int  // 1-3
    
    func matches(_ match: LineMatch) -> Bool {
        return match.ingredient == ingredient && match.length == quantity
    }
}
```

**OrderManager** maintains 4 active orders and handles fulfillment.

### 4. Cascade System

**File**: `GameState.swift` → `collectCascades()`

After each match:
1. Apply gravity
2. Scan entire grid for 4-in-a-row
3. If found: award star, clear cells, apply gravity
4. Repeat until no more 4-in-a-rows

```swift
private func collectCascades() -> [CascadeRound] {
    var cascades: [CascadeRound] = []
    
    while true {
        let matches = grid.findAllMatches(minLength: 4)
        if matches.isEmpty { break }
        
        let drops = grid.clearAndApplyGravity(matches, with: availableIngredients)
        cascades.append(CascadeRound(matches: matches, drops: drops))
    }
    
    return cascades
}
```

### 5. Contiguous Run Detection

**File**: `GameScene.swift` → `findContiguousRuns(in:)`

Finds uninterrupted sequences of the same ingredient:

```
Row: [🍜] [🍜] [🥚] [🍜]
      └─┬─┘       └─┬─┘
      Run 1      Run 2
     (🍜x2)     (🍜x1)
```

### 6. Animation System

**File**: `GameScene.swift`

Animations are sequenced:
1. `animateMatchResult()` - Orchestrates full sequence
2. `animateClearCells()` - Scale up + fade out + particle
3. `animateDrops()` - Gravity fall with bounce
4. `animateCascades()` - Sequential cascade rounds
5. `showStarEarnedEffect()` - Floating ⭐ burst

---

## File Structure

```
RamenRush/
├── RamenRush/
│   ├── Models/
│   │   ├── IngredientType.swift    # 16 ingredient types + categories
│   │   ├── GridPosition.swift      # Position struct + line generation
│   │   ├── GridCell.swift          # Single cell container
│   │   ├── GameGrid.swift          # 4x4 grid + gravity + matching
│   │   ├── GameState.swift         # Game state + cascade processing
│   │   ├── Order.swift             # Complex order (unused legacy)
│   │   ├── SimpleOrder.swift       # Simple x1/x2/x3 orders
│   │   └── ProgressionManager.swift # Level unlocks
│   │
│   ├── Game/
│   │   └── GameScene.swift         # SpriteKit scene + animations
│   │
│   ├── Views/
│   │   ├── GameView.swift          # SwiftUI wrapper for SpriteKit
│   │   └── ContentView.swift       # App root view
│   │
│   └── RamenRushApp.swift          # App entry point
│
├── RamenRushTests/
│   ├── GridPositionTests.swift
│   ├── GameGridTests.swift
│   ├── IngredientTypeTests.swift
│   ├── ProgressionManagerTests.swift
│   ├── OrderTests.swift
│   └── GameStateTests.swift
│
├── Documentation/
│   ├── project.md                  # Design document
│   ├── README.md                   # Quick start
│   ├── GAME_INSTRUCTIONS.md        # Player guide
│   └── TECHNICAL_DOCUMENTATION.md  # This file
```

---

## Data Models

### GridPosition

```swift
struct GridPosition: Hashable, Codable {
    let row: Int
    let column: Int
    
    func isValid(for gridSize: Int) -> Bool
    func horizontalLine(length: Int, gridSize: Int) -> [GridPosition]
    func verticalLine(length: Int, gridSize: Int) -> [GridPosition]
}
```

### GridCell

```swift
struct GridCell: Codable {
    var ingredient: IngredientType?
    var isSelected: Bool = false
    var isEmpty: Bool { ingredient == nil }
}
```

### IngredientType

```swift
enum IngredientType: String, Codable, CaseIterable {
    // 16 types across 4 categories
    case ramen, udon, soba, riceNoodles           // Noodles
    case chashu, softBoiledEgg, tofu, tempuraShrimp // Proteins
    case greenOnions, nori, bambooShoots, bokChoy  // Vegetables
    case ramenBowl, donburiBowl, bentoBox, sushiPlate // Bowls
    
    var category: IngredientCategory
    var unlockLevel: Int
    var displayName: String
    var emoji: String
    var placeholderColor: Color
}
```

### LineMatch

```swift
struct LineMatch: Codable {
    let positions: [GridPosition]
    let ingredient: IngredientType
    var length: Int { positions.count }
}
```

### MatchResult

```swift
struct MatchResult {
    let clearedPositions: [GridPosition]
    let initialDrops: [IngredientDrop]
    let cascades: [CascadeRound]
    
    var totalStarsEarned: Int {
        cascades.reduce(0) { $0 + $1.matches.count }
    }
}
```

### CascadeRound

```swift
struct CascadeRound {
    let matches: [LineMatch]
    let drops: [IngredientDrop]
}
```

### IngredientDrop

```swift
struct IngredientDrop {
    let ingredient: IngredientType
    let fromPosition: GridPosition  // Negative row = from preview
    let toPosition: GridPosition
    
    var dropDistance: Int
    var isFromPreview: Bool
}
```

---

## Game Flow

### Initialization

```
App Launch
    ↓
GameView created
    ↓
GameScene initialized with GameGrid + GameState
    ↓
gameState.startLevel(1)
    ↓
- Set available ingredients (4 basic types)
- Generate 4 orders
- Fill grid with random ingredients
- Initialize preview queue
```

### Turn Flow

```
1. Player taps grid
       ↓
2. selectLine(at: position)
   - Get full row or column
   - Call findAndProcessMatches()
       ↓
3. findContiguousRuns()
   - Find all uninterrupted sequences
       ↓
4. Match against orders
   - Prioritize runs containing tapped cell
   - Find first run that matches an order
       ↓
5. gameState.processMatch()
   - Clear matched cells
   - Apply gravity
   - Collect cascades (4-in-a-row detection)
   - Award stars
   - Return MatchResult
       ↓
6. animateMatchResult()
   - Clear animation
   - Drop animation
   - Cascade animations (sequential)
   - Star effects
       ↓
7. Update display
   - Grid refreshed
   - Preview updated
   - Player can make next move
```

### Cascade Flow

```
After gravity applied:
    ↓
while (true) {
    matches = findAllMatches(minLength: 4)
    if (matches.isEmpty) break
    
    stars += matches.count
    clearAndApplyGravity(matches)
}
```

---

## Key Algorithms

### 1. Contiguous Run Detection

```swift
func findContiguousRuns(in positions: [GridPosition]) -> [LineMatch] {
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
            currentRun.append(pos)
        } else {
            // Save previous run, start new one
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
```

### 2. Gravity Application

```swift
func applyGravity(with availableIngredients: [IngredientType]) -> [IngredientDrop] {
    var drops: [IngredientDrop] = []
    
    for col in 0..<size {
        // 1. Collect existing ingredients with original rows
        var existing: [(ingredient: IngredientType, originalRow: Int)] = []
        for row in (0..<size).reversed() {
            if let cell = cell(at: GridPosition(row, col)),
               let ingredient = cell.ingredient {
                existing.append((ingredient, row))
            }
        }
        existing.reverse()
        
        // 2. Get new ingredients from preview queue
        let emptyCount = size - existing.count
        var newIngredients: [IngredientType] = []
        for _ in 0..<emptyCount {
            if !upcomingIngredients[col].isEmpty {
                newIngredients.append(upcomingIngredients[col].removeFirst())
                upcomingIngredients[col].append(availableIngredients.randomElement()!)
            }
        }
        
        // 3. Rebuild column and track drops
        for row in 0..<size {
            if row < emptyCount {
                // New ingredient from preview
                let ingredient = newIngredients[row]
                drops.append(IngredientDrop(
                    ingredient: ingredient,
                    fromPosition: GridPosition(row - emptyCount, col),
                    toPosition: GridPosition(row, col)
                ))
                setIngredient(ingredient, at: GridPosition(row, col))
            } else {
                // Existing ingredient
                let (ingredient, originalRow) = existing[row - emptyCount]
                if originalRow != row {
                    drops.append(IngredientDrop(
                        ingredient: ingredient,
                        fromPosition: GridPosition(originalRow, col),
                        toPosition: GridPosition(row, col)
                    ))
                }
                setIngredient(ingredient, at: GridPosition(row, col))
            }
        }
    }
    
    return drops
}
```

### 3. Four-in-a-Row Detection

```swift
func findHorizontalMatches(minLength: Int = 4) -> [LineMatch] {
    var matches: [LineMatch] = []
    
    for row in 0..<size {
        var currentIngredient: IngredientType?
        var currentLength = 0
        var startColumn = 0
        
        for col in 0..<size {
            let ingredient = cell(at: GridPosition(row, col))?.ingredient
            
            if ingredient == currentIngredient && ingredient != nil {
                currentLength += 1
            } else {
                if currentLength >= minLength, let ing = currentIngredient {
                    matches.append(LineMatch(
                        positions: (startColumn..<startColumn+currentLength).map { 
                            GridPosition(row, $0) 
                        },
                        ingredient: ing
                    ))
                }
                currentIngredient = ingredient
                currentLength = 1
                startColumn = col
            }
        }
        
        // Check end of row
        if currentLength >= minLength, let ing = currentIngredient {
            matches.append(LineMatch(
                positions: (startColumn..<startColumn+currentLength).map { 
                    GridPosition(row, $0) 
                },
                ingredient: ing
            ))
        }
    }
    
    return matches
}
```

---

## UI/UX Components

### GameScene Layout

```
┌─────────────────────────────┐
│      HUD (Stars, Level)     │  ← 80pt top margin
├─────────────────────────────┤
│   [Preview Row - half vis]  │  ← Shows upcoming ingredients
├─────────────────────────────┤
│                             │
│      4×4 Game Grid          │  ← 60pt cells, 4pt spacing
│                             │
├─────────────────────────────┤
│    [Order Cards × 4]        │  ← 220pt bottom margin
│    [Control Buttons]        │
└─────────────────────────────┘
```

### Visual Elements

| Element | Size | Color |
|---------|------|-------|
| Grid Cell | 60×60pt | White |
| Cell Border | 2pt | #5C4033 (Dark Wood) |
| Cursor | 64×64pt | #D32F2F (Red Lantern) |
| Background | Full | #FFF8E7 (Cream) |
| Preview Cell | 60×30pt | White @ 60% alpha |

### Animations

| Animation | Duration | Effect |
|-----------|----------|--------|
| Cell Clear | 0.3s | Scale 1.3x → fade out → reset |
| Drop | 0.15s/cell | Ease-in + bounce (4pt) |
| Cascade Highlight | 0.2s | Flash gold (#FFB300) |
| Star Earned | 0.8s | Float up + scale + fade |

---

## Testing

### Test Framework

Uses **Swift Testing** (not XCTest):

```swift
import Testing
@testable import RamenRush

@Suite("Grid Tests")
struct GameGridTests {
    @Test func testGridInitialization() {
        let grid = GameGrid(size: 4)
        #expect(grid.size == 4)
    }
}
```

### Test Coverage

| Area | File | Coverage |
|------|------|----------|
| Grid Operations | GameGridTests.swift | Basic ops, matching, gravity |
| Positions | GridPositionTests.swift | Validation, line generation |
| Ingredients | IngredientTypeTests.swift | Properties, unlocks |
| Progression | ProgressionManagerTests.swift | Level unlocks |
| Orders | OrderTests.swift | SimpleOrder, OrderManager |
| Game State | GameStateTests.swift | Match processing, cascades |

### Running Tests

```bash
# Xcode
Cmd+U

# Command Line
xcodebuild test -project RamenRush.xcodeproj \
    -scheme RamenRush \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Known Issues & Bugs

### Current Issues

1. **Animation Timing**: Sometimes animations can overlap if player taps quickly during cascade
   - **Severity**: Low
   - **Workaround**: Wait for animations to complete
   - **Fix**: Add input blocking during animations

2. **Preview Row Position**: May need adjustment on different screen sizes
   - **Severity**: Low
   - **Fix**: Calculate based on safe area insets

3. **No Win/Lose Detection**: Game doesn't detect when player is stuck or wins
   - **Severity**: High
   - **Fix**: Implement game over detection and win condition

4. **No Power-Up System**: Stars are earned but can't be spent
   - **Severity**: Medium
   - **Fix**: Implement power-up menu and actions

5. **No Sound Effects**: Game is silent
   - **Severity**: Medium
   - **Fix**: Add audio manager and sound assets

### Legacy Code

- `Order.swift` contains complex order system (unused)
- Should be removed or marked as deprecated

---

## Future Improvements

### High Priority

1. **Win/Lose Conditions**
   - Detect when no valid moves exist
   - Track order deck completion
   - Show game over / victory screens

2. **Power-Up System**
   - Shuffle board
   - Clear row/column
   - Hint system
   - Spend stars to activate

3. **Audio**
   - Background music
   - Sound effects for matches, cascades, stars

4. **Save System**
   - Persist game state
   - iCloud sync
   - High scores

### Medium Priority

5. **Tutorial**
   - First-time player onboarding
   - Interactive hints

6. **Level System**
   - Multiple levels with increasing difficulty
   - New ingredients unlock

7. **Visual Polish**
   - Replace placeholder colors with pixel art sprites
   - Add Chef Hiro character

8. **Haptics**
   - Vibration feedback for matches and cascades

### Low Priority

9. **Accessibility**
   - VoiceOver support
   - Color blind modes

10. **Analytics**
    - Track player behavior
    - Optimize difficulty curve

11. **Achievements**
    - GameCenter integration
    - In-game achievements

---

## Development Setup

### Requirements

- macOS 12.0+
- Xcode 15.0+
- iOS 18.5+ deployment target (can be lowered)

### Getting Started

```bash
# Clone repository
git clone <repo-url>
cd RamenRush

# Open in Xcode
open RamenRush.xcodeproj

# Configure signing
# 1. Select RamenRush target
# 2. Signing & Capabilities
# 3. Select your Team

# Run
Cmd+R
```

### Project Configuration

- **Bundle ID**: com.yourcompany.RamenRush
- **Deployment Target**: iOS 18.5
- **Device Orientation**: Portrait only
- **Supported Devices**: iPhone, iPad

---

## Coding Conventions

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful names (no abbreviations except common ones like `col`, `pos`)
- Add documentation comments for public APIs

### File Organization

```swift
// MARK: - Properties

// MARK: - Initialization

// MARK: - Public Methods

// MARK: - Private Methods

// MARK: - Extensions
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Types | PascalCase | `GameState`, `LineMatch` |
| Functions | camelCase | `processMatch()`, `applyGravity()` |
| Variables | camelCase | `currentLevel`, `gridSize` |
| Constants | camelCase | `defaultSize`, `maxOrders` |
| Enums | PascalCase | `IngredientType`, `CursorDirection` |

### Best Practices

1. **Use value types** (structs) for data, reference types (classes) for state
2. **Prefer composition** over inheritance
3. **Keep functions small** and single-purpose
4. **Write tests** for new features
5. **Document complex logic** with comments
6. **Use @Published** for observable state

### Git Workflow

```bash
# Feature branch
git checkout -b feature/power-ups

# Commit with descriptive message
git commit -m "Add power-up system with shuffle and clear abilities

- Implement PowerUpManager
- Add power-up menu UI
- Deduct stars when using power
- Add animations for power effects"

# Push and create PR
git push origin feature/power-ups
```

---

## Quick Reference

### Important Classes

| Class | Responsibility |
|-------|---------------|
| `GameState` | Central game logic, processes matches |
| `GameGrid` | Grid data, gravity, pattern detection |
| `GameScene` | Rendering, touch handling, animations |
| `OrderManager` | Manages 4 active orders |
| `ProgressionManager` | Level-based unlocks |

### Key Methods

| Method | Location | Purpose |
|--------|----------|---------|
| `processMatch()` | GameState | Process player match, collect cascades |
| `applyGravity()` | GameGrid | Drop ingredients, fill from top |
| `findContiguousRuns()` | GameScene | Find ingredient sequences in line |
| `findAllMatches()` | GameGrid | Detect 4-in-a-row patterns |
| `animateMatchResult()` | GameScene | Orchestrate all animations |

### State Flow

```
User Tap → GameScene.selectLine() 
         → GameScene.findAndProcessMatches()
         → GameState.processMatch()
         → GameGrid.clearAndApplyGravity()
         → GameState.collectCascades()
         → GameScene.animateMatchResult()
         → Display Updated
```

---

## Contact & Resources

- **Design Document**: `Documentation/project.md`
- **Player Guide**: `Documentation/GAME_INSTRUCTIONS.md`
- **README**: `README.md`

---

*Last Updated: November 20, 2025*
