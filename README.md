# 🍜 Ramen Rush

**Serve steaming bowls of happiness!**

Ramen Rush is a cozy puzzle/match-line game where you help Chef Hiro serve delicious ramen to hungry customers. Match lines of ingredients to fulfill orders and build your noodle empire!

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)
- [Project Structure](#project-structure)
- [Game Mechanics](#game-mechanics)
- [Development](#development)
- [Contributing](#contributing)

## ✨ Features

- **16 Unique Ingredients** - Unlock noodles, proteins, vegetables, and bowls as you progress
- **4×4 Grid Gameplay** - Match lines of ingredients, inspired by classic puzzle games
- **Simple Order System** - Fulfill customer orders (x1, x2, or x3 of same ingredient)
- **Touch & Button Controls** - Tap the grid directly or use arrow buttons
- **Star Rewards** - Earn stars for completing orders
- **Auto-Refill Grid** - Cleared cells automatically refill with new ingredients
- **Progression System** - Unlock new ingredients at specific levels
- **SpriteKit Rendering** - Smooth animations and responsive touch controls

## 🔧 Requirements

### Development Environment

- **Xcode**: 15.0 or later (recommended: latest version)
- **Swift**: 5.0+
- **iOS Deployment Target**: iOS 18.5+ (may need adjustment for older devices)
- **macOS**: macOS 12.0 or later (for development)

### Runtime Requirements

- **iOS**: 18.5 or later
- **Device**: iPhone or iPad
- **Simulator**: iOS Simulator supported for development

## 🚀 Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd RamenRush
```

### 2. Open in Xcode

```bash
open RamenRush.xcodeproj
```

Or simply double-click `RamenRush.xcodeproj` in Finder.

### 3. Configure Signing

1. Select the `RamenRush` target in Xcode
2. Go to **Signing & Capabilities**
3. Select your **Team** from the dropdown
4. Xcode will automatically generate a provisioning profile

### 4. Select a Simulator or Device

- **Simulator**: Choose any iPhone or iPad simulator from the device menu
- **Physical Device**: Connect your iPhone/iPad via USB and select it from the device menu

## ▶️ Running the App

### Using Xcode

1. **Select a target device** (simulator or connected device) from the device menu
2. **Press** `⌘R` (Command + R) or click the **Run** button (▶️)
3. The app will build and launch automatically

### Using Command Line

```bash
# Build and run on default simulator
xcodebuild -project RamenRush.xcodeproj -scheme RamenRush -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

# Or use xcodebuild to build, then install via Xcode
```

### First Launch

On first launch, the game will:
- Initialize a **4×4 grid** with 4 random ingredients (matching original Pico-8 game)
- Generate **4 customer orders** showing ingredient + quantity (x1, x2, or x3)
- Display the game grid with ingredient emojis (🍜🥚🥩🥬)
- Show order cards at the bottom of the screen

## 🧪 Running Tests

### Using Xcode

1. **Press** `⌘U` (Command + U) or go to **Product → Test**
2. All tests will run automatically
3. View results in the **Test Navigator** (⌘6)

### Using Command Line

```bash
# Run all tests
xcodebuild test -project RamenRush.xcodeproj -scheme RamenRush -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -project RamenRush.xcodeproj -scheme RamenRush -only-testing:RamenRushTests/GridPositionTests
```

### Test Coverage

The project includes comprehensive unit tests for:

- ✅ **GridPosition** - Position validation, line generation
- ✅ **GameGrid** - Grid operations, matching logic
- ✅ **IngredientType** - All 16 ingredients, categories, unlocks
- ✅ **ProgressionManager** - Level progression, ingredient unlocks
- ✅ **Order** - Order fulfillment, progress tracking
- ✅ **GameState** - Game state management

**Test Framework**: Swift Testing (modern Swift testing framework)

## 📁 Project Structure

```
RamenRush/
├── RamenRush/
│   ├── Models/              # Core game models
│   │   ├── IngredientType.swift
│   │   ├── GridPosition.swift
│   │   ├── GridCell.swift
│   │   ├── GameGrid.swift
│   │   ├── GameState.swift
│   │   ├── Order.swift
│   │   ├── SimpleOrder.swift
│   │   └── ProgressionManager.swift
│   ├── Game/                # SpriteKit game scene
│   │   └── GameScene.swift
│   ├── Views/               # SwiftUI views
│   │   ├── GameView.swift
│   │   └── ContentView.swift
│   ├── Resources/           # Assets (sprites, audio)
│   │   ├── Audio/
│   │   └── Sprites/
│   ├── Assets.xcassets/     # Image assets
│   ├── RamenRushApp.swift   # App entry point
│   └── Documentation/       # Project documentation
│       └── project.md
├── RamenRushTests/          # Unit tests
│   ├── GridPositionTests.swift
│   ├── GameGridTests.swift
│   ├── IngredientTypeTests.swift
│   ├── ProgressionManagerTests.swift
│   ├── OrderTests.swift
│   └── GameStateTests.swift
├── README.md                # This file
├── IPHONE_USER_GUIDE.md     # Detailed iPhone user guide
├── TESTING_GUIDE.md         # Testing checklist
└── FIX_SUMMARY.md           # Recent layout fixes
```

## 🎮 Game Mechanics

### How to Play

1. **Select a Line**: Tap on the grid or use the cursor controls to select a horizontal or vertical line of cells
2. **Match Orders**: Select lines that match the customer orders shown at the bottom
3. **Fulfill Orders**: Orders show ingredient + quantity (e.g., 🍜x2 means 2 ramen in a line)
4. **Earn Stars**: Complete orders to earn stars and progress to the next level
5. **Auto-Refill**: After matching, cleared cells automatically refill with random ingredients
6. **Unlock Ingredients**: New ingredients unlock as you advance through levels

### Controls

- **Touch**: Tap on the grid to select a line at that position
- **Arrow Buttons**: Move the cursor around the 4×4 grid (↑↓←→)
- **Rotate Button**: Switch between horizontal and vertical line selection (⟳)
- **Cursor**: Red outline shows your current selection
- **Pause**: Tap [⏸] in top right to pause the game

### Order System (Like Original Game)

- **4 Order Cards** displayed at bottom of screen
- Each order shows: **Ingredient Emoji + Quantity**
  - **x1** = Select 1 of that ingredient
  - **x2** = Select 2 of that ingredient in a line
  - **x3** = Select 3 of that ingredient in a line
- Match a line to an order to complete it
- New orders appear as you complete them
- Game starts with 4 basic ingredients: 🍜 🥚 🥩 🥬

### Ingredient Unlocks

| Level | Ingredient |
|-------|-----------|
| 0 (Start) | Ramen, Chashu, Soft-Boiled Egg, Green Onions, Ramen Bowl |
| 3 | Udon |
| 4 | Tofu |
| 5 | Nori |
| 6 | Soba |
| 7 | Tempura Shrimp |
| 8 | Bamboo Shoots |
| 9 | Rice Noodles |
| 10 | Bok Choy |
| 11 | Donburi Bowl |
| 13 | Bento Box |
| 15 | Sushi Plate |

## 🛠️ Development

### Architecture

- **Framework**: SpriteKit for game rendering, SwiftUI for UI
- **Pattern**: MVVM-inspired with ObservableObject for state management
- **Language**: Swift 5.0+
- **Testing**: Swift Testing framework

### Key Components

#### Models
- `IngredientType`: Enum defining all 16 ingredients with unlock levels and emojis
- `GameGrid`: Manages the **4×4 game board** and matching logic
- `GameState`: Tracks level, stars, coins, and current orders
- `SimpleOrder`: Represents customer orders (ingredient + quantity)
- `OrderManager`: Manages the 4 order cards (like original game)
- `ProgressionManager`: Handles ingredient unlocking based on level

#### Views
- `GameView`: Main SwiftUI view wrapping the SpriteKit scene
- `GameScene`: SpriteKit scene handling rendering and touch input

### Adding New Features

1. **New Ingredients**: Add to `IngredientType` enum with appropriate unlock level
2. **New Game Modes**: Extend `GameState` with new state management
3. **UI Elements**: Add SwiftUI views in `Views/` directory
4. **Sprites**: Add sprite assets to `Resources/Sprites/` (currently using placeholder colors)

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and single-purpose
- Use `@Published` for ObservableObject properties

## 🎨 Assets

### Current Status

- ✅ **Placeholder Colors**: All ingredients have placeholder colors from the design spec
- ⏳ **Sprites**: Pixel art sprites pending (see `Documentation/project.md` for specifications)
- ⏳ **Audio**: Music and sound effects pending

### Adding Sprites

When sprites are ready:
1. Add sprite images to `Resources/Sprites/`
2. Update `GameScene.swift` to load and display sprites instead of placeholder colors
3. Ensure sprites follow the 32×32 pixel base size (export at 2x/3x for retina)

## 🐛 Troubleshooting

### Build Errors

**"Cannot find type 'UIEvent' in scope"**
- ✅ Fixed: Ensure `import UIKit` is present in `GameScene.swift`

**Signing Errors**
- Select your development team in Signing & Capabilities
- Ensure your Apple Developer account is configured

**Simulator Issues**
- Reset simulator: Device → Erase All Content and Settings
- Try a different simulator model

### Runtime Issues

**Grid not displaying or cut off**
- ✅ Fixed: Grid positioning updated in GameScene.swift (November 2025)
- Grid should be centered between top HUD and bottom order cards
- If still having issues, see `FIX_SUMMARY.md` for details

**Grid underneath order cards**
- ✅ Fixed: Grid positioning calculations corrected
- Grid uses proper coordinate system with margins for UI elements

**Touch not working**
- Ensure SpriteKit scene is properly sized
- Check that touch handling is enabled in `GameScene`
- Try using arrow button controls instead

**Cursor misaligned**
- ✅ Fixed: Cursor positioning now matches grid exactly
- All three positioning methods use consistent calculations

## 📝 License

[Add your license here]

## 👥 Contributing

[Add contribution guidelines here]

## 📚 Additional Documentation

- **[iPhone User Guide](IPHONE_USER_GUIDE.md)** - Step-by-step guide for playing on iPhone
- **[Testing Guide](TESTING_GUIDE.md)** - Comprehensive testing checklist
- **[Fix Summary](FIX_SUMMARY.md)** - Recent layout fixes and improvements
- **[Project Documentation](RamenRush/Documentation/project.md)** - Detailed technical specs

## 📞 Support

For issues, questions, or suggestions:
- Check the IPHONE_USER_GUIDE.md for gameplay help
- Check TESTING_GUIDE.md for known issues
- Review FIX_SUMMARY.md for recent updates

---

**Made with 🍜**

