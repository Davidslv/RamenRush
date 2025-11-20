//
//  MainMenuView.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#FFF8E7")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                VStack(spacing: 10) {
                    Text("🍜")
                        .font(.system(size: 80))
                    Text("Ramen Rush")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#3E2723"))
                    Text("Serve steaming bowls of happiness!")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#5C4033"))
                        .italic()
                }
                
                Spacer()
                
                // Menu Buttons
                VStack(spacing: 20) {
                    MenuButton(
                        title: "Play",
                        icon: "play.fill",
                        color: Color(hex: "#66BB6A")
                    ) {
                        showGame = true
                    }
                    
                    MenuButton(
                        title: "Settings",
                        icon: "gearshape.fill",
                        color: Color(hex: "#FFB300")
                    ) {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Footer
                Text("Premium Game - No Ads")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#8B6F47"))
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF8E7")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.title)
                        .padding()
                    
                    // Placeholder for settings
                    Text("Settings coming soon!")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MainMenuView()
}

