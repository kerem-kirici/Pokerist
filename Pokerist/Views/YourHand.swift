//
//  YourHandSection.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI

struct YourHandSection: View {
    var gameState: GameState
    
    var body: some View {
        HStack {
            // Show exactly two selection slots
            ForEach(0..<2) { index in
                // Create bindings that use GameState action functions
                let suitBinding = Binding<Suit?> (
                    get: {
                        index < gameState.playerCards.count ? gameState.playerCards[index].suit : nil
                    },
                    set: { newValue in
                        let currentRank = index < gameState.playerCards.count ? gameState.playerCards[index].rank : nil
                        gameState.updatePlayerCard(at: index, suit: newValue, rank: currentRank)
                    }
                )

                let rankBinding = Binding<Rank?> (
                    get: {
                        index < gameState.playerCards.count ? gameState.playerCards[index].rank : nil
                    },
                    set: { newValue in
                        let currentSuit = index < gameState.playerCards.count ? gameState.playerCards[index].suit : nil
                        gameState.updatePlayerCard(at: index, suit: currentSuit, rank: newValue)
                    }
                )
                
                let editingCard = index < gameState.playerCards.count ? gameState.playerCards[index] : nil

                SelectCardButton(
                    selectedSuit: suitBinding,
                    selectedRank: rankBinding,
                    gameState: gameState,
                    editingCard: editingCard
                )
                .medium()
            }
            Spacer()

        }
    }
}

#Preview {
    YourHandSection_Preview()
}

private struct YourHandSection_Preview: View {
    @State private var gameState = GameState()
    var body: some View {
        YourHandSection(gameState: gameState)
    }
}
