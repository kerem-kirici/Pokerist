//
//  InformationSection.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI

struct InformationSection: View {
    var gameState: GameState
    @State private var isWinProbabilityExpanded = false
    @State private var isPossibleHandsExpanded = false
    
    private var analysis: HandAnalysisResult {
        PokerHandAnalyzer.analyze(
            playerCards: gameState.playerCards,
            communityCards: gameState.communityCards
        )
    }
    
    private var revealedCommunityCards: Int {
        gameState.communityCards.filter { $0.suit != nil && $0.rank != nil }.count
    }
    
    private var validPlayerCards: Int {
        gameState.playerCards.filter { $0.suit != nil && $0.rank != nil }.count
    }
    
    private var hasBothPlayerCards: Bool {
        validPlayerCards >= 2
    }
    
    private var hasOnePlayerCard: Bool {
        validPlayerCards == 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Check if player has selected both cards
            if !hasBothPlayerCards {
                // Show message to select both player cards
                PlaceholderCard(message: "Select \(hasOnePlayerCard ? "the remaining player card" : "both of the player cards") to see the analysis")
            } else {
                
                // Win Probability Section (Expandable - includes opponent hands, async calculated)
                WinProbabilityCard(
                    probability: analysis.winProbability,  // nil when async loading
                    currentHand: analysis.currentHand,
                    canExpand: analysis.hasMinimumCards,  // Only expandable with 3+ community cards
                    cacheKey: analysis.cacheKey,
                    playerCards: gameState.playerCards,
                    communityCards: gameState.communityCards,
                    isExpanded: $isWinProbabilityExpanded
                )
                .id(analysis.cacheKey)  // Recreate view when cards change
                .onChange(of: analysis.cacheKey) { oldValue, newValue in
                    // Close expansion when cards change
                    if oldValue != newValue && !oldValue.isEmpty {
                        isWinProbabilityExpanded = false
                        isPossibleHandsExpanded = false
                    }
                }
                
                // Advanced analysis (only with minimum cards: 2 player + 3 community)
                if analysis.hasMinimumCards {
                    // Possible Hands for Player (Expandable - async loading)
                    PossibleHandsCard(
                        canExpand: true,
                        cacheKey: analysis.cacheKey,
                        playerCards: gameState.playerCards,
                        communityCards: gameState.communityCards,
                        isExpanded: $isPossibleHandsExpanded
                    )
                    .id(analysis.cacheKey)  // Recreate view when cards change
                } else if revealedCommunityCards < 3 {
                    PlaceholderCard(message: "Reveal at least 3 community cards to see detailed analysis")
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    InformationSection_Preview()
}

private struct InformationSection_Preview: View {
    @State private var gameState = GameState()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Poker Hand Analysis")
                    .font(.title.bold())
                
                InformationSection(gameState: gameState)
                
                Group {
                    // Demo: Three of a Kind expanded list layout
                    VStack(alignment: .leading, spacing: 12) {
                        // Header-like button style
                        Text("Three of a Kind")
                            .font(.headline)
                            .padding(.vertical, 6)

                        // Rows with left label and right probability
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Text("2 Aces")
                                        .font(.subheadline)
                                    // Example tiny cards for illustration
                                    CardView(rank: .ace).xsmall()
                                    CardView(rank: .ace).xsmall()
                                }
                                Spacer()
                                Text("14.2%")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                HStack(spacing: 6) {
                                    Text("2 Kings")
                                        .font(.subheadline)
                                    CardView(rank: .king).xsmall()
                                    CardView(rank: .king).xsmall()
                                }
                                Spacer()
                                Text("11.8%")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .padding(.top, 8)
                }
                
                // Test different scenarios
                HStack(spacing: 12) {
                    Button("No Cards") {
                        gameState.playerCards = [.empty, .empty]
                        gameState.communityCards = [.empty, .empty, .empty, .empty, .empty]
                    }
                    .buttonStyle(.bordered)
                    
                    Button("One Card") {
                        gameState.playerCards = [
                            PlayingCard(suit: .heart, rank: .ace),
                            .empty
                        ]
                        gameState.communityCards = [.empty, .empty, .empty, .empty, .empty]
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Both Cards") {
                        gameState.playerCards = [
                            PlayingCard(suit: .heart, rank: .ace),
                            PlayingCard(suit: .heart, rank: .king)
                        ]
                        gameState.communityCards = [
                            PlayingCard(suit: .heart, rank: .queen),
                            PlayingCard(suit: .heart, rank: .jack),
                            PlayingCard(suit: .diamond, rank: .ten),
                            .empty,
                            .empty
                        ]
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .onAppear {
            // Start with empty cards to show the message
            gameState.playerCards = [.empty, .empty]
            gameState.communityCards = [.empty, .empty, .empty, .empty, .empty]
        }
    }
}

