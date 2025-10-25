//
//  GameState.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI
import Observation

/// Central state management for the poker game (Redux-like pattern)
/// 
/// This class provides a single source of truth for all card data in the game,
/// similar to Redux in React. It automatically prevents duplicate cards from being
/// selected by disabling options in the card picker based on what's already selected.
///
/// Example Usage:
/// ```swift
/// @State private var gameState = GameState()
/// YourHandSection(gameState: gameState)
/// ```
@Observable
class GameState {
    // MARK: - State
    var playerCards: [PlayingCard] = [.empty, .empty]
    var communityCards: [PlayingCard] = [.empty, .empty, .empty, .empty, .empty]
    var opponentHands: [[PlayingCard]] = []
    
    // Mock hand
    //var playerCards: [PlayingCard] = [PlayingCard(suit: .club, rank: .eight), PlayingCard(suit: .diamond, rank: .seven)]
    //var communityCards: [PlayingCard] = [PlayingCard(suit: .club, rank: .two), PlayingCard(suit: .diamond, rank: .six), PlayingCard(suit: .diamond, rank: .five), .empty, .empty]
    
    // MARK: - Computed Properties
    
    /// All cards that have been fully selected (both suit and rank)
    var allSelectedCards: [PlayingCard] {
        let player = playerCards.filter { $0.suit != nil && $0.rank != nil }
        let community = communityCards.filter { $0.suit != nil && $0.rank != nil }
        let opponents = opponentHands.flatMap { $0.filter { $0.suit != nil && $0.rank != nil } }
        return player + community + opponents
    }
    
    // MARK: - Card Selection Logic
    
    /// Determines if a suit should be disabled based on current selection and already selected cards
    /// - Parameters:
    ///   - suit: The suit to check
    ///   - currentRank: The currently selected rank (if any)
    ///   - excludingCard: The card being edited (to exclude it from the check)
    /// - Returns: True if the suit should be disabled
    func isSuitDisabled(_ suit: Suit, withCurrentRank currentRank: Rank?, excludingCard: PlayingCard?) -> Bool {
        // If no rank is selected yet, don't disable any suits
        guard let rank = currentRank else {
            return false
        }
        
        // Check if this combination already exists in selected cards
        return allSelectedCards.contains { card in
            // Skip the card we're currently editing
            if let excludingCard = excludingCard,
               card.suit == excludingCard.suit && card.rank == excludingCard.rank {
                return false
            }
            // Disable if this suit+rank combo already exists
            return card.suit == suit && card.rank == rank
        }
    }
    
    /// Determines if a rank should be disabled based on current selection and already selected cards
    /// - Parameters:
    ///   - rank: The rank to check
    ///   - currentSuit: The currently selected suit (if any)
    ///   - excludingCard: The card being edited (to exclude it from the check)
    /// - Returns: True if the rank should be disabled
    func isRankDisabled(_ rank: Rank, withCurrentSuit currentSuit: Suit?, excludingCard: PlayingCard?) -> Bool {
        // If no suit is selected yet, don't disable any ranks
        guard let suit = currentSuit else {
            return false
        }
        
        // Check if this combination already exists in selected cards
        return allSelectedCards.contains { card in
            // Skip the card we're currently editing
            if let excludingCard = excludingCard,
               card.suit == excludingCard.suit && card.rank == excludingCard.rank {
                return false
            }
            // Disable if this suit+rank combo already exists
            return card.suit == suit && card.rank == rank
        }
    }
    
    // MARK: - Actions (Redux-like)
    
    /// Updates a player card at a specific index
    func updatePlayerCard(at index: Int, suit: Suit?, rank: Rank?) {
        guard index >= 0 else { return }
        
        // Ensure backing storage exists up to this index
        while playerCards.count <= index {
            playerCards.append(.empty)
        }
        
        playerCards[index] = PlayingCard(suit: suit, rank: rank)
    }
    
    /// Updates a community card at a specific index
    func updateCommunityCard(at index: Int, suit: Suit?, rank: Rank?) {
        guard index >= 0 else { return }
        
        // Ensure backing storage exists up to this index
        while communityCards.count <= index {
            communityCards.append(.empty)
        }
        
        communityCards[index] = PlayingCard(suit: suit, rank: rank)
    }
    
    /// Resets all cards to empty
    func resetAllCards() {
        playerCards = [.empty, .empty]
        communityCards = [.empty, .empty, .empty, .empty, .empty]
    }
    
    /// Resets player cards only
    func resetPlayerCards() {
        playerCards = [.empty, .empty]
    }
    
    /// Resets community cards only
    func resetCommunityCards() {
        communityCards = [.empty, .empty, .empty, .empty, .empty]
    }
    
    // MARK: - Opponent Hands Management
    
    /// Sets the number of opponent hands
    func setOpponentCount(_ count: Int) {
        guard count >= 0 else { return }
        
        // Initialize or resize opponent hands array
        while opponentHands.count < count {
            opponentHands.append([.empty, .empty])
        }
        
        // Remove excess hands if count is reduced
        if count < opponentHands.count {
            opponentHands = Array(opponentHands.prefix(count))
        }
    }
    
    /// Updates an opponent card at a specific hand and card index
    func updateOpponentCard(handIndex: Int, cardIndex: Int, suit: Suit?, rank: Rank?) {
        guard handIndex >= 0 && handIndex < opponentHands.count else { return }
        guard cardIndex >= 0 && cardIndex < 2 else { return }
        
        opponentHands[handIndex][cardIndex] = PlayingCard(suit: suit, rank: rank)
    }
    
    /// Resets all opponent hands
    func resetOpponentHands() {
        opponentHands = []
    }
}

