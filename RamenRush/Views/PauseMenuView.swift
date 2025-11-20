//
//  PauseMenuView.swift
//  RamenRush
//
//  Created by David Silva on 20/11/2025.
//

import SwiftUI

struct PauseMenuView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    let onResume: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("⏸")
                    .font(.system(size: 60))

                Text("Paused")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    Button(action: {
                        onResume()
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#66BB6A"))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        onQuit()
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Quit to Menu")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#EF5350"))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding(30)
            .background(Color(hex: "#FFF8E7"))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    PauseMenuView(
        isPresented: .constant(true),
        onResume: {},
        onQuit: {}
    )
}

