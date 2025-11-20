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
}
