//
//  OrderCompleteView.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SwiftUI

struct OrderCompleteView: View {
    let starsEarned: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("✨")
                    .font(.system(size: 60))
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("Order Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    ForEach(0..<starsEarned, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                }
                .opacity(opacity)

                Text("+\(starsEarned) Star\(starsEarned == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .opacity(opacity)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#FFF8E7"))
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    opacity = 0
                } completion: {
                    onDismiss()
                }
            }
        }
    }
}

#Preview {
    OrderCompleteView(starsEarned: 2, onDismiss: {})
}

