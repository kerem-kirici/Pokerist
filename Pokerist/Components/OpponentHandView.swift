//
//  OpponentHandView.swift
//  Pokerist
//
//  Created by Kerem Kirici on 25.10.2025.
//

import SwiftUI

struct OpponentHandView: View {
    let gameState: GameState
    let handIndex: Int
    let opponentNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Opponent label
            Text("Opponent \(opponentNumber)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            // Two card selection buttons
            HStack(spacing: 4) {
                ForEach(0..<2) { cardIndex in
                    let suitBinding = Binding<Suit?>(
                        get: {
                            guard handIndex < gameState.opponentHands.count,
                                  cardIndex < gameState.opponentHands[handIndex].count else {
                                return nil
                            }
                            return gameState.opponentHands[handIndex][cardIndex].suit
                        },
                        set: { newValue in
                            let currentRank = handIndex < gameState.opponentHands.count && 
                                            cardIndex < gameState.opponentHands[handIndex].count ? 
                                            gameState.opponentHands[handIndex][cardIndex].rank : nil
                            gameState.updateOpponentCard(handIndex: handIndex, cardIndex: cardIndex, suit: newValue, rank: currentRank)
                        }
                    )
                    
                    let rankBinding = Binding<Rank?>(
                        get: {
                            guard handIndex < gameState.opponentHands.count,
                                  cardIndex < gameState.opponentHands[handIndex].count else {
                                return nil
                            }
                            return gameState.opponentHands[handIndex][cardIndex].rank
                        },
                        set: { newValue in
                            let currentSuit = handIndex < gameState.opponentHands.count && 
                                            cardIndex < gameState.opponentHands[handIndex].count ? 
                                            gameState.opponentHands[handIndex][cardIndex].suit : nil
                            gameState.updateOpponentCard(handIndex: handIndex, cardIndex: cardIndex, suit: currentSuit, rank: newValue)
                        }
                    )
                    
                    let editingCard = handIndex < gameState.opponentHands.count && 
                                    cardIndex < gameState.opponentHands[handIndex].count ? 
                                    gameState.opponentHands[handIndex][cardIndex] : nil
                    
                    SelectCardButton(
                        selectedSuit: suitBinding,
                        selectedRank: rankBinding,
                        gameState: gameState,
                        editingCard: editingCard
                    )
                    .xsmall()
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        OpponentHandView(
            gameState: GameState(),
            handIndex: 0,
            opponentNumber: 1
        )
        
        OpponentHandView(
            gameState: GameState(),
            handIndex: 1,
            opponentNumber: 2
        )
    }
    .padding()
}
