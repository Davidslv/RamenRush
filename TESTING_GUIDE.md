# RamenRush Testing Guide

## ✅ Pre-Test Checklist

All code has been verified:
- ✅ No linter errors in GameScene.swift
- ✅ No linter errors in GameView.swift
- ✅ No linter errors in all Model files
- ✅ Grid positioning calculations are correct and consistent
- ✅ 4x4 grid structure matches original game design

## 🎮 What to Test

### 1. Grid Display (CRITICAL)
When you launch the game, verify:

- [ ] **Grid is fully visible** - All 16 cells (4x4) should be on screen
- [ ] **Grid is centered** - Grid should be in the middle area of the screen
- [ ] **Grid is NOT underneath order cards** - There should be clear space between the grid and the bottom order cards
- [ ] **Grid is NOT outside screen bounds** - No cells should be cut off at bottom

Expected layout on vertical iPhone:
```
┌─────────────────────┐
│  [Lvl 1] [⭐0] [⏸]  │  ← Top HUD (80pt)
├─────────────────────┤
│                     │
│   🍜  🥚  🥩  🥬   │
│   🥩  🍜  🥬  🥚   │  ← 4x4 Grid
│   🥚  🥩  🍜  🥬   │     (252x252pt)
│   🥬  🥚  🥩  🍜   │
│                     │
├─────────────────────┤
│ [🍜x2] [🥚x1] ...  │  ← Order Cards (100pt)
│                     │
│ [↑][←][⟳][→][↓]   │  ← Controls (100pt)
└─────────────────────┘
```

### 2. Game Mechanics
Test the core gameplay:

- [ ] **Grid loads with random ingredients** - Should see 4 different emojis (🍜🥚🥩🥬)
- [ ] **4 order cards appear at bottom** - Each showing ingredient + quantity (x1, x2, or x3)
- [ ] **Controls are responsive** - Arrow buttons move cursor, rotate button changes orientation
- [ ] **Cursor is visible** - Red outline highlighting current selection
- [ ] **Cursor can be horizontal or vertical** - Pressing rotate button toggles

### 3. Matching System
Test the order fulfillment:

- [ ] **Tap on grid to select line** - Should select 4 cells in a row/column
- [ ] **Matching ingredients fulfill orders** - e.g., if you have "🍜x2" order and select 2 ramen in a line, it should match
- [ ] **Stars increase when order completed** - Counter at top should increment
- [ ] **Grid refills after match** - Cleared cells should be replaced with new random ingredients
- [ ] **New order appears** - A new order card should replace the completed one

### 4. Touch & Cursor Interaction
Verify input works correctly:

- [ ] **Touch detection works** - Tapping on a cell selects that line
- [ ] **Arrow buttons work** - Move cursor to different positions
- [ ] **Rotate button works** - Toggles between horizontal and vertical selection
- [ ] **Cursor position matches grid** - Cursor outline should perfectly align with cells

### 5. Visual & Layout
Check the overall appearance:

- [ ] **Cells are properly sized** - Each cell should be 60pt x 60pt
- [ ] **Spacing is consistent** - 4pt gap between cells
- [ ] **Ingredients are visible** - Emojis should be clear and readable
- [ ] **Order cards are readable** - Can clearly see ingredient emoji and quantity
- [ ] **No overlapping UI** - All elements should have clear boundaries

## 🐛 Known Issues to Watch For

If you see any of these, please report:

1. **Grid too low** - Bottom row of grid is cut off or hidden by order cards
2. **Grid too high** - Grid touches or overlaps with top HUD
3. **Cursor misaligned** - Red outline doesn't match cell positions
4. **Touch detection off** - Tapping a cell selects wrong cell or doesn't work
5. **UI overlap** - Order cards cover part of the grid

## 📱 Test Devices

Please test on:
- iPhone 15 (6.1" display - 393x852pt)
- iPhone 15 Pro Max (6.7" display - 430x932pt)
- iPhone SE (4.7" display - 375x667pt)

The layout should work on all these sizes!

## 🎯 Expected Behavior (Like Original)

The game should play like the original Pico-8 game:

1. **4x4 Grid** - Always 4 rows x 4 columns
2. **4 Order Cards** - Show what customers want
3. **Select Lines** - Choose horizontal or vertical lines of 4 cells
4. **Match Orders** - If your line matches an order (same ingredient, right quantity), you complete it
5. **Earn Stars** - Get stars for completing orders
6. **Refill Grid** - Empty cells automatically refill with random ingredients
7. **Win Condition** - Complete all orders to win the level
8. **Lose Condition** - Get stuck with no valid moves (not implemented yet)

## ✅ Success Criteria

The game is ready if:

1. ✅ Grid displays correctly on all iPhone sizes
2. ✅ Grid is fully visible (not cut off)
3. ✅ Grid doesn't overlap with order cards
4. ✅ Controls work (touch, arrows, rotate)
5. ✅ Order matching works
6. ✅ Grid refills after matches
7. ✅ Stars increase on completion
8. ✅ Game is playable and fun!

## 🚀 Next Steps After Testing

Once the layout is confirmed working:

1. Test gameplay for 5-10 minutes
2. Try to complete at least 3 orders
3. Verify the grid refill system works
4. Check that new orders appear
5. Confirm the game feels responsive and playable

## 📝 Feedback Template

When reporting results, please note:

**Device:** iPhone 15
**iOS Version:** 17.x
**Grid Display:** ✅ Visible, centered, not cut off
**Order Cards:** ✅ Visible at bottom
**Controls:** ✅ All buttons work
**Gameplay:** ✅ Can complete orders
**Issues:** None / [describe any issues]

---

**Ready to test!** 🎮🍜

