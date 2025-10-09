//
//  CommunityCards.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI

struct CommunityCardsSection: View {
    var gameState: GameState
    
    var body: some View {
        HStack {
            // Show exactly five selection slots
            ForEach(0..<5) { index in
                // Create bindings that use GameState action functions
                let suitBinding = Binding<Suit?> (
                    get: {
                        index < gameState.communityCards.count ? gameState.communityCards[index].suit : nil
                    },
                    set: { newValue in
                        let currentRank = index < gameState.communityCards.count ? gameState.communityCards[index].rank : nil
                        gameState.updateCommunityCard(at: index, suit: newValue, rank: currentRank)
                    }
                )

                let rankBinding = Binding<Rank?> (
                    get: {
                        index < gameState.communityCards.count ? gameState.communityCards[index].rank : nil
                    },
                    set: { newValue in
                        let currentSuit = index < gameState.communityCards.count ? gameState.communityCards[index].suit : nil
                        gameState.updateCommunityCard(at: index, suit: currentSuit, rank: newValue)
                    }
                )
                
                let editingCard = index < gameState.communityCards.count ? gameState.communityCards[index] : nil

                SelectCardButton(
                    selectedSuit: suitBinding,
                    selectedRank: rankBinding,
                    gameState: gameState,
                    editingCard: editingCard
                )
                .small()
            }
            Spacer()

        }
    }
}

#Preview {
    CommunityCardsSection_Preview()
}


private struct CommunityCardsSection_Preview: View {
    @State private var gameState = GameState()
    var body: some View {
        CommunityCardsSection(gameState: gameState)
    }
}
