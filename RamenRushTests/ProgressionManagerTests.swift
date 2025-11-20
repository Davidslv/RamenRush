//
//  ProgressionManagerTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct ProgressionManagerTests {

    @Test func testUnlockIngredientsLevel0() {
        let unlocked = ProgressionManager.unlockIngredients(forLevel: 0)

        // Should have 5 starting ingredients
        #expect(unlocked.count == 5)
        #expect(unlocked.contains(.ramen))
        #expect(unlocked.contains(.chashu))
        #expect(unlocked.contains(.softBoiledEgg))
        #expect(unlocked.contains(.greenOnions))
        #expect(unlocked.contains(.ramenBowl))
    }

    @Test func testUnlockIngredientsLevel3() {
        let unlocked = ProgressionManager.unlockIngredients(forLevel: 3)

        // Should have starting ingredients + udon
        #expect(unlocked.contains(.ramen))
        #expect(unlocked.contains(.udon))
        #expect(!unlocked.contains(.tofu)) // Unlocks at level 4
    }

    @Test func testUnlockIngredientsLevel15() {
        let unlocked = ProgressionManager.unlockIngredients(forLevel: 15)

        // Should have all ingredients
        #expect(unlocked.count == 16)
        #expect(unlocked.contains(.sushiPlate))
    }

    @Test func testNextUnlock() {
        let next = ProgressionManager.nextUnlock(currentLevel: 0)
        #expect(next == .udon)
        #expect(next?.unlockLevel == 3)
    }

    @Test func testNextUnlockLevel3() {
        let next = ProgressionManager.nextUnlock(currentLevel: 3)
        #expect(next == .tofu)
        #expect(next?.unlockLevel == 4)
    }

    @Test func testNextUnlockMaxLevel() {
        let next = ProgressionManager.nextUnlock(currentLevel: 15)
        #expect(next == nil) // No more unlocks
    }

    @Test func testProgressToNextUnlock() {
        let progress = ProgressionManager.progressToNextUnlock(currentLevel: 2)

        #expect(progress != nil)
        #expect(progress?.current == 2)
        #expect(progress?.needed == 3) // Next unlock is udon at level 3
    }

    @Test func testProgressToNextUnlockMaxLevel() {
        let progress = ProgressionManager.progressToNextUnlock(currentLevel: 15)
        #expect(progress == nil) // No more unlocks
    }

    @Test func testIsUnlocked() {
        #expect(ProgressionManager.isUnlocked(.ramen, at: 0))
        #expect(ProgressionManager.isUnlocked(.ramen, at: 10))

        #expect(!ProgressionManager.isUnlocked(.udon, at: 2))
        #expect(ProgressionManager.isUnlocked(.udon, at: 3))
    }

    @Test func testUnlockedIngredientsByCategory() {
        let byCategory = ProgressionManager.unlockedIngredientsByCategory(at: 5)

        // Should have noodles, proteins, vegetables, bowls
        #expect(byCategory[.noodles] != nil)
        #expect(byCategory[.proteins] != nil)
        #expect(byCategory[.vegetables] != nil)
        #expect(byCategory[.bowls] != nil)

        // Verify counts
        let noodles = byCategory[.noodles] ?? []
        #expect(noodles.contains(.ramen))
        #expect(noodles.contains(.udon))
        #expect(!noodles.contains(.soba)) // Unlocks at level 6
    }
}

