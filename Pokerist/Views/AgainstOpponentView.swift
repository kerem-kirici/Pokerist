//
//  AgainstOpponentView.swift
//  Pokerist
//
//  Created by Kerem Kirici on 25.10.2025.
//

import SwiftUI

struct AgainstOpponentView: View {
    let gameState: GameState
    
    @State var opponentCount = 1
    @State var isOn: Bool = false
    
    var body: some View {
        // Glassy wrapper container
        ZStack {
            // Enhanced glass background
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial) // core glass
                .background(
                    // Slight tinted gradient behind the material to simulate depth
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    // Soft inner glow for liquid-like highlight
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .blendMode(.overlay)
                )
                .overlay(
                    // Specular highlight band
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blur(radius: 8)
                        .padding(.horizontal, 6)
                        .padding(.top, 4)
                        .mask(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                        .allowsHitTesting(false)
                )
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $isOn) {
                    Text("Against Opponent\(opponentCount == 1 ? "" : "s")")
                        .font(.headline)
                }
                if isOn {
                    Stepper("Total Count: \(opponentCount)", value: $opponentCount, in: 0...6)
                        .font(.body)
                    
                    // Opponent hands section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Opponent Hands")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(0..<opponentCount, id: \.self) { index in
                                OpponentHandView(
                                    gameState: gameState,
                                    handIndex: index,
                                    opponentNumber: index + 1
                                )
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(16)
        }
        .onChange(of: isOn) { _, newValue in
            opponentCount = newValue ? 1 : 0
            gameState.setOpponentCount(opponentCount)
        }
        .onChange(of: opponentCount) { _, newValue in
            isOn = newValue > 0
            gameState.setOpponentCount(newValue)
        }
    }
}

#Preview {
    AgainstOpponentView_Preview()
}

private struct AgainstOpponentView_Preview: View {
    @State private var gameState = GameState()
    var body: some View {
       AgainstOpponentView(gameState: gameState)
    }
}
