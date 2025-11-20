//
//  SimpleOrderCard.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SwiftUI

struct SimpleOrderCard: View {
    let order: SimpleOrder
    
    var body: some View {
        VStack(spacing: 4) {
            // Ingredient icon
            Circle()
                .fill(order.ingredient.placeholderColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Quantity
            Text(order.displayText)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(width: 60, height: 80)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    HStack {
        SimpleOrderCard(order: SimpleOrder(ingredient: .ramen, quantity: 1))
        SimpleOrderCard(order: SimpleOrder(ingredient: .chashu, quantity: 2))
        SimpleOrderCard(order: SimpleOrder(ingredient: .softBoiledEgg, quantity: 3))
    }
    .padding()
}

