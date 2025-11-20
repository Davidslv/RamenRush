//
//  GameView.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var grid: GameGrid
    @StateObject private var gameState: GameState
    @State private var gameScene: GameScene?

    init() {
        // Create grid first, then game state that references it
        let newGrid = GameGrid()
        _grid = StateObject(wrappedValue: newGrid)
        _gameState = StateObject(wrappedValue: GameState(grid: newGrid))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene
                if let scene = gameScene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                } else {
                    Color(hex: "#FFF8E7")
                        .ignoresSafeArea()
                }

                // UI Overlay
                VStack {
                    // Top HUD
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Level \(gameState.currentLevel)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Stars: \(gameState.stars)")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }

                        Spacer()

                        if let order = gameState.currentOrder {
                            OrderCard(order: order)
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFF8E7").opacity(0.9))

                    Spacer()

                    // Bottom Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            gameScene?.moveCursor(direction: .up)
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#66BB6A"))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            gameScene?.moveCursor(direction: .left)
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#66BB6A"))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            gameScene?.rotateCursor()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#FFB300"))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            gameScene?.moveCursor(direction: .right)
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#66BB6A"))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            gameScene?.moveCursor(direction: .down)
                        }) {
                            Image(systemName: "arrow.down")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "#66BB6A"))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFF8E7").opacity(0.9))
                }
            }
            .onAppear {
                setupGameScene(size: geometry.size)
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                gameScene?.size = newSize
            }
        }
    }

    private func setupGameScene(size: CGSize) {
        let scene = GameScene(size: size, grid: grid, gameState: gameState)
        scene.scaleMode = .aspectFill
        gameScene = scene
        gameState.startLevel(1)
    }
}

struct OrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Order")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(order.requiredIngredients, id: \.ingredient.id) { requirement in
                HStack {
                    Circle()
                        .fill(requirement.ingredient.placeholderColor)
                        .frame(width: 16, height: 16)
                    Text("\(requirement.quantity)x")
                        .font(.caption)
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
    }
}

#Preview {
    GameView()
}

