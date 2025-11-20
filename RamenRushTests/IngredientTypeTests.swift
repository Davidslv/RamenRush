//
//  IngredientTypeTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct IngredientTypeTests {

    @Test func testAllIngredientsExist() {
        // Verify all 16 ingredients are present
        let allIngredients = IngredientType.allCases
        #expect(allIngredients.count == 16)
    }

    @Test func testCategoryAssignment() {
        #expect(IngredientType.ramen.category == .noodles)
        #expect(IngredientType.chashu.category == .proteins)
        #expect(IngredientType.greenOnions.category == .vegetables)
        #expect(IngredientType.ramenBowl.category == .bowls)
    }

    @Test func testUnlockLevels() {
        // Starting ingredients should be unlocked at level 0
        #expect(IngredientType.ramen.unlockLevel == 0)
        #expect(IngredientType.chashu.unlockLevel == 0)
        #expect(IngredientType.softBoiledEgg.unlockLevel == 0)
        #expect(IngredientType.greenOnions.unlockLevel == 0)
        #expect(IngredientType.ramenBowl.unlockLevel == 0)

        // Later ingredients
        #expect(IngredientType.udon.unlockLevel == 3)
        #expect(IngredientType.tofu.unlockLevel == 4)
        #expect(IngredientType.nori.unlockLevel == 5)
        #expect(IngredientType.soba.unlockLevel == 6)
        #expect(IngredientType.tempuraShrimp.unlockLevel == 7)
        #expect(IngredientType.bambooShoots.unlockLevel == 8)
        #expect(IngredientType.riceNoodles.unlockLevel == 9)
        #expect(IngredientType.bokChoy.unlockLevel == 10)
        #expect(IngredientType.donburiBowl.unlockLevel == 11)
        #expect(IngredientType.bentoBox.unlockLevel == 13)
        #expect(IngredientType.sushiPlate.unlockLevel == 15)
    }

    @Test func testIsUnlocked() {
        #expect(IngredientType.ramen.isUnlocked(at: 0))
        #expect(IngredientType.ramen.isUnlocked(at: 5))

        #expect(!IngredientType.udon.isUnlocked(at: 2))
        #expect(IngredientType.udon.isUnlocked(at: 3))
        #expect(IngredientType.udon.isUnlocked(at: 5))
    }

    @Test func testDisplayNames() {
        #expect(IngredientType.ramen.displayName == "Ramen")
        #expect(IngredientType.chashu.displayName == "Chashu Pork")
        #expect(IngredientType.softBoiledEgg.displayName == "Soft-Boiled Egg")
        #expect(IngredientType.riceNoodles.displayName == "Rice Noodles")
    }

    @Test func testPlaceholderColors() {
        // Verify all ingredients have placeholder colors
        for ingredient in IngredientType.allCases {
            let color = ingredient.placeholderColor
            // Just verify it's a valid color (not nil)
            #expect(color != nil)
        }
    }

    @Test func testIdentifiable() {
        let ingredient = IngredientType.ramen
        #expect(ingredient.id == "ramen")
    }
}

