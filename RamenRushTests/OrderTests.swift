//
//  OrderTests.swift
//  RamenRushTests
//
//  Created by David Silva on 20/11/2025.
//

import Testing
@testable import RamenRush

struct OrderTests {

    @Test func testOrderCreation() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 4)
        ]
        let reward = OrderReward(stars: 1)
        let order = Order(requiredIngredients: requirements, reward: reward)

        #expect(order.requiredIngredients.count == 1)
        #expect(order.reward.stars == 1)
        #expect(!order.isCompleted)
    }

    @Test func testCanFulfillExactMatch() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 4)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 1)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            )
        ]

        #expect(order.canFulfill(with: matches))
    }

    @Test func testCanFulfillMultipleMatches() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 8)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 2)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            ),
            LineMatch(
                positions: [
                    GridPosition(1, 0),
                    GridPosition(1, 1),
                    GridPosition(1, 2),
                    GridPosition(1, 3)
                ],
                ingredient: .ramen
            )
        ]

        #expect(order.canFulfill(with: matches))
    }

    @Test func testCanFulfillMultipleIngredients() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 4),
            IngredientRequirement(ingredient: .chashu, quantity: 4)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 2)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            ),
            LineMatch(
                positions: [
                    GridPosition(1, 0),
                    GridPosition(1, 1),
                    GridPosition(1, 2),
                    GridPosition(1, 3)
                ],
                ingredient: .chashu
            )
        ]

        #expect(order.canFulfill(with: matches))
    }

    @Test func testCannotFulfillInsufficient() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 8)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 2)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            )
        ]

        #expect(!order.canFulfill(with: matches))
    }

    @Test func testCompletionProgress() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 8)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 2)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            )
        ]

        let progress = order.completionProgress(with: matches)
        #expect(progress == 0.5) // 4 out of 8
    }

    @Test func testCompletionProgressComplete() {
        let requirements = [
            IngredientRequirement(ingredient: .ramen, quantity: 4)
        ]
        let order = Order(
            requiredIngredients: requirements,
            reward: OrderReward(stars: 1)
        )

        let matches = [
            LineMatch(
                positions: [
                    GridPosition(0, 0),
                    GridPosition(0, 1),
                    GridPosition(0, 2),
                    GridPosition(0, 3)
                ],
                ingredient: .ramen
            )
        ]

        let progress = order.completionProgress(with: matches)
        #expect(progress == 1.0)
    }

    @Test func testOrderGenerator() {
        let order = OrderGenerator.generateOrder(
            level: 1,
            availableIngredients: [.ramen, .chashu],
            difficulty: .easy
        )

        #expect(order != nil)
        #expect(!order.requiredIngredients.isEmpty)
        #expect(order.reward.stars > 0)
    }

    @Test func testOrderDifficulty() {
        let easy = OrderDifficulty.easy
        #expect(easy.baseStars == 1)
        #expect(easy.baseCoins == nil)

        let normal = OrderDifficulty.normal
        #expect(normal.baseStars == 2)
        #expect(normal.baseCoins == 10)

        let hard = OrderDifficulty.hard
        #expect(hard.baseStars == 3)
        #expect(hard.baseCoins == 25)
    }
    
    // MARK: - SimpleOrder Tests (x1, x2, x3 matching)
    
    @Test func testSimpleOrderCreation() {
        let order = SimpleOrder(ingredient: .ramen, quantity: 2)
        
        #expect(order.ingredient == .ramen)
        #expect(order.quantity == 2)
        #expect(order.displayText == "x2")
    }
    
    @Test func testSimpleOrderQuantityClamping() {
        // Test minimum clamping
        let tooLow = SimpleOrder(ingredient: .ramen, quantity: 0)
        #expect(tooLow.quantity == 1)
        
        // Test maximum clamping (orders are x1, x2, x3 only)
        let tooHigh = SimpleOrder(ingredient: .ramen, quantity: 5)
        #expect(tooHigh.quantity == 3)
        
        // Test valid range
        let valid = SimpleOrder(ingredient: .ramen, quantity: 2)
        #expect(valid.quantity == 2)
    }
    
    @Test func testSimpleOrderMatches() {
        let order = SimpleOrder(ingredient: .ramen, quantity: 2)
        
        // Exact match - should work
        let exactMatch = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .ramen
        )
        #expect(order.matches(exactMatch))
        
        // Wrong quantity - should fail
        let tooFew = LineMatch(
            positions: [GridPosition(0, 0)],
            ingredient: .ramen
        )
        #expect(!order.matches(tooFew))
        
        let tooMany = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2)],
            ingredient: .ramen
        )
        #expect(!order.matches(tooMany))
        
        // Wrong ingredient - should fail
        let wrongIngredient = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .chashu
        )
        #expect(!order.matches(wrongIngredient))
    }
    
    @Test func testSimpleOrderX1() {
        let order = SimpleOrder(ingredient: .softBoiledEgg, quantity: 1)
        
        let match = LineMatch(
            positions: [GridPosition(2, 3)],
            ingredient: .softBoiledEgg
        )
        
        #expect(order.matches(match))
        #expect(order.displayText == "x1")
    }
    
    @Test func testSimpleOrderX3() {
        let order = SimpleOrder(ingredient: .greenOnions, quantity: 3)
        
        let match = LineMatch(
            positions: [
                GridPosition(1, 0),
                GridPosition(1, 1),
                GridPosition(1, 2)
            ],
            ingredient: .greenOnions
        )
        
        #expect(order.matches(match))
        #expect(order.displayText == "x3")
    }
    
    // MARK: - OrderManager Tests
    
    @Test func testOrderManagerFulfillOrder() {
        let manager = OrderManager()
        
        // Add some orders
        manager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 2))
        manager.addOrder(SimpleOrder(ingredient: .chashu, quantity: 3))
        manager.addOrder(SimpleOrder(ingredient: .softBoiledEgg, quantity: 1))
        
        // Try to fulfill with a matching line
        let match = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .ramen
        )
        
        let fulfilled = manager.fulfillOrder(with: match)
        #expect(fulfilled != nil)
        #expect(fulfilled?.ingredient == .ramen)
        #expect(fulfilled?.quantity == 2)
    }
    
    @Test func testOrderManagerNoMatch() {
        let manager = OrderManager()
        
        manager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 2))
        manager.addOrder(SimpleOrder(ingredient: .chashu, quantity: 3))
        
        // Try with wrong quantity
        let wrongQuantity = LineMatch(
            positions: [GridPosition(0, 0)],
            ingredient: .ramen
        )
        #expect(manager.fulfillOrder(with: wrongQuantity) == nil)
        
        // Try with wrong ingredient
        let wrongIngredient = LineMatch(
            positions: [GridPosition(0, 0), GridPosition(0, 1)],
            ingredient: .tofu
        )
        #expect(manager.fulfillOrder(with: wrongIngredient) == nil)
    }
    
    @Test func testOrderManagerGenerateOrders() {
        let manager = OrderManager()
        let ingredients: [IngredientType] = [.ramen, .chashu, .softBoiledEgg, .greenOnions]
        
        manager.generateOrders(availableIngredients: ingredients, count: 4)
        
        #expect(manager.orders.count == 4)
        
        // All orders should have valid ingredients and quantities (x1, x2, x3)
        for order in manager.orders {
            #expect(ingredients.contains(order.ingredient))
            #expect(order.quantity >= 1 && order.quantity <= 3)
        }
    }
    
    @Test func testOrderManagerMaxOrders() {
        let manager = OrderManager()
        
        // Try to add more than max
        for _ in 0..<10 {
            manager.addOrder(SimpleOrder(ingredient: .ramen, quantity: 1))
        }
        
        #expect(manager.orders.count == 4)  // Max is 4
    }
}
