//
//  SimpleOrder.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import Foundation

/// Simple order matching the original Pico-8 game
/// Each order is just: ingredient + quantity (x1, x2, or x3)
struct SimpleOrder: Identifiable, Codable {
    let id: UUID
    let ingredient: IngredientType
    let quantity: Int  // 1, 2, or 3
    
    init(id: UUID = UUID(), ingredient: IngredientType, quantity: Int) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = max(1, min(3, quantity))  // Clamp to 1-3
    }
    
    /// Check if a line match fulfills this order
    func matches(_ match: LineMatch) -> Bool {
        return match.ingredient == ingredient && match.length == quantity
    }
    
    var displayText: String {
        "x\(quantity)"
    }
}

/// Manages multiple orders (like cards at bottom in original)
class OrderManager: ObservableObject {
    @Published var orders: [SimpleOrder] = []
    private let maxOrders = 4
    
    /// Add a new order
    func addOrder(_ order: SimpleOrder) {
        guard orders.count < maxOrders else { return }
        orders.append(order)
    }
    
    /// Remove an order
    func removeOrder(_ order: SimpleOrder) {
        orders.removeAll { $0.id == order.id }
    }
    
    /// Check if a match fulfills any order
    func fulfillOrder(with match: LineMatch) -> SimpleOrder? {
        return orders.first { $0.matches(match) }
    }
    
    /// Generate random orders from available ingredients
    func generateOrders(availableIngredients: [IngredientType], count: Int = 4) {
        orders = []
        for _ in 0..<min(count, maxOrders) {
            let ingredient = availableIngredients.randomElement() ?? .ramen
            let quantity = Int.random(in: 1...3)
            addOrder(SimpleOrder(ingredient: ingredient, quantity: quantity))
        }
    }
}

