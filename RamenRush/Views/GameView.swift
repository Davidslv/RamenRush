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
    @State private var showPauseMenu = false
    @State private var showOrderComplete = false
    @Environment(\.dismiss) var dismiss

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

                        // Pause Button
                        Button(action: {
                            showPauseMenu = true
                            gameScene?.isPaused = true
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "#8B6F47"))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .background(Color(hex: "#FFF8E7").opacity(0.9))

                    Spacer()

                    // Order Cards (at bottom like original)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(gameState.orderManager.orders) { order in
                                SimpleOrderCard(order: order)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 100)
                    .background(Color(hex: "#FFF8E7").opacity(0.95))
                    .padding(.bottom, 20)

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
            .overlay {
                if showPauseMenu {
                    PauseMenuView(
                        isPresented: $showPauseMenu,
                        onResume: {
                            gameScene?.isPaused = false
                        },
                        onQuit: {
                            dismiss()
                        }
                    )
                }

                if showOrderComplete && gameState.lastOrderStarsEarned > 0 {
                    OrderCompleteView(starsEarned: gameState.lastOrderStarsEarned) {
                        showOrderComplete = false
                    }
                }
            }
            .onChange(of: gameState.lastOrderStarsEarned) { oldValue, newValue in
                if newValue > 0 {
                    showOrderComplete = true
                }
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Order")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }

            ForEach(order.requiredIngredients, id: \.ingredient.id) { requirement in
                HStack(spacing: 6) {
                    Circle()
                        .fill(requirement.ingredient.placeholderColor)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.5)
                        )
                    Text("\(requirement.quantity)x")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    GameView()
}

