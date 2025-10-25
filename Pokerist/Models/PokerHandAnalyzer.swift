//
//  PokerHandAnalyzer.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import Foundation

// MARK: - Hand Types
enum PokerHandType: String, CaseIterable {
    case royalFlush = "Royal Flush"
    case straightFlush = "Straight Flush"
    case fourOfAKind = "Four of a Kind"
    case fullHouse = "Full House"
    case flush = "Flush"
    case straight = "Straight"
    case threeOfAKind = "Three of a Kind"
    case twoPair = "Two Pair"
    case onePair = "One Pair"
    case highCard = "High Card"
    
    nonisolated var rank: Int {
        switch self {
        case .royalFlush: return 10
        case .straightFlush: return 9
        case .fourOfAKind: return 8
        case .fullHouse: return 7
        case .flush: return 6
        case .straight: return 5
        case .threeOfAKind: return 4
        case .twoPair: return 3
        case .onePair: return 2
        case .highCard: return 1
        }
    }
    
    nonisolated var icon: String {
        switch self {
        case .royalFlush, .straightFlush: return "crown.fill"
        case .fourOfAKind: return "square.stack.3d.up.fill"
        case .fullHouse: return "house.fill"
        case .flush: return "suit.diamond.fill"
        case .straight: return "arrow.right"
        case .threeOfAKind: return "square.stack.fill"
        case .twoPair: return "square.2.stack.3d"
        case .onePair: return "square.2.stack.3d.top.filled"
        case .highCard: return "hand.raised.fill"
        }
    }
}

// MARK: - Possible Hand
struct PossibleHand: Identifiable {
    let id = UUID()
    let handType: PokerHandType
    let requiredCards: [String]
    let probability: Double
}

struct CombinedPossibleHands: Identifiable {
    let id = UUID()
    let handType: PokerHandType
    let requiredCombinations: [[String]]
    let probabilities: [Double]
    let totalProbability: Double
}

// MARK: - Opponent Hand
struct OpponentHand: Identifiable {
    let id = UUID()
    let handType: PokerHandType
    let exampleHoleCards: [(Rank, Suit)]  // Example of 2 cards that make this hand
    let combinations: Int  // Number of possible combinations
    let probability: Double
}

// MARK: - Hand Analysis Result
struct HandAnalysisResult {
    let currentHand: PokerHandType?
    let possibleHands: [PossibleHand]  // Empty when async loading needed
    let winProbability: Double?  // Nil when async loading needed
    let opponentWinProbabilities: [Double]  // Win probabilities for each opponent
    let hasMinimumCards: Bool  // Whether we have enough cards to analyze
    let cacheKey: String  // Key for caching results
}

// MARK: - Poker Hand Analyzer
class PokerHandAnalyzer {
    
    // Simulation configuration
    nonisolated static let simulationCount = 10000
    
    /// Analyzes the current game state and returns possible hands
    static func analyze(playerCards: [PlayingCard], communityCards: [PlayingCard], opponentHands: [[PlayingCard]] = []) -> HandAnalysisResult {
        let validPlayerCards = playerCards.filter { $0.suit != nil && $0.rank != nil }
        let validCommunityCards = communityCards.filter { $0.suit != nil && $0.rank != nil }
        
        // Check if we have minimum cards (2 player + 3 community)
        let hasMinimumCards = validPlayerCards.count >= 2 && validCommunityCards.count >= 3
        
        // Need at least player cards for basic analysis
        guard validPlayerCards.count == 2 else {
            return HandAnalysisResult(
                currentHand: nil,
                possibleHands: [],
                winProbability: nil,
                opponentWinProbabilities: [],
                hasMinimumCards: false,
                cacheKey: ""
            )
        }
        
        let allCards = validPlayerCards + validCommunityCards
        
        // Evaluate current hand
        let currentHand = evaluateHand(cards: allCards)
        
        // Generate cache key for async calculations
        let cacheKey = generateCacheKey(playerCards: validPlayerCards, communityCards: validCommunityCards, opponentHands: opponentHands)
        
        return HandAnalysisResult(
            currentHand: currentHand,
            possibleHands: [],  // Empty - calculated async
            winProbability: nil,  // Nil - calculated async
            opponentWinProbabilities: [],  // Empty - calculated async
            hasMinimumCards: hasMinimumCards,
            cacheKey: cacheKey
        )
    }
    
    // MARK: - Hand Evaluation
    
    nonisolated static func evaluateHand(cards: [PlayingCard]) -> PokerHandType? {
        guard cards.count >= 2 else { return nil }
        
        let suits = cards.compactMap { $0.suit }
        let ranks = cards.compactMap { $0.rank }
        
        // Check for flush (5+ of same suit)
        let suitCounts = Dictionary(grouping: suits, by: { $0 }).mapValues { $0.count }
        let hasFlush = suitCounts.values.contains { $0 >= 5 }
        
        // Check for straight
        let hasStraight = checkStraight(ranks: ranks)
        
        // Rank counts
        let rankCounts = Dictionary(grouping: ranks, by: { $0 }).mapValues { $0.count }
        let counts = rankCounts.values.sorted(by: >)
        
        // Evaluate
        if hasFlush && hasStraight {
            if isRoyalFlush(ranks: ranks) {
                return .royalFlush
            }
            return .straightFlush
        }
        
        if counts.first == 4 { return .fourOfAKind }
        if counts.count >= 2 && counts[0] == 3 && counts[1] >= 2 { return .fullHouse }
        if hasFlush { return .flush }
        if hasStraight { return .straight }
        if counts.first == 3 { return .threeOfAKind }
        if counts.count >= 2 && counts[0] == 2 && counts[1] == 2 { return .twoPair }
        if counts.first == 2 { return .onePair }
        
        return .highCard
    }
    
    nonisolated private static func checkStraight(ranks: [Rank]) -> Bool {
        guard ranks.count >= 5 else { return false }
        
        let values = Set(ranks.map { rankValue($0) })
        
        // Check for regular straights
        for start in 0...9 {
            let straightValues = Set(start..<(start + 5))
            if straightValues.isSubset(of: values) {
                return true
            }
        }
        
        // Check for wheel (A-2-3-4-5)
        let wheelValues: Set<Int> = [0, 1, 2, 3, 12] // 2,3,4,5,A
        if wheelValues.isSubset(of: values) {
            return true
        }
        
        return false
    }
    
    // called only when there is a flush and straight already
    nonisolated private static func isRoyalFlush(ranks: [Rank]) -> Bool {
        let royalRanks: Set<Rank> = [.ten, .jack, .queen, .king, .ace]
        let currentRanks = Set(ranks)
        return royalRanks.isSubset(of: currentRanks)
    }
    
    nonisolated private static func rankValue(_ rank: Rank) -> Int {
        switch rank {
        case .two: return 0
        case .three: return 1
        case .four: return 2
        case .five: return 3
        case .six: return 4
        case .seven: return 5
        case .eight: return 6
        case .nine: return 7
        case .ten: return 8
        case .jack: return 9
        case .queen: return 10
        case .king: return 11
        case .ace: return 12
        }
    }
    
    /// Nonisolated version of suit name for display
    nonisolated private static func suitName(_ suit: Suit) -> String {
        switch suit {
        case .spade: return "Spades"
        case .heart: return "Hearts"
        case .club: return "Clubs"
        case .diamond: return "Diamonds"
        }
    }
    
    /// Nonisolated version of rank display
    nonisolated private static func rankDisplay(_ rank: Rank) -> String {
        switch rank {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }
    
    // MARK: - Possible Hands Calculation

    nonisolated private static func appendPossibleHands(
        to possibleHands: inout [PossibleHand],
        handType: PokerHandType,
        requiredCards: [String],
        probability: Double,
        neededCopies: Int = 1
    ) {
        // Split distinct rank outcomes into separate PossibleHand entries
        let uniqueRanks = Array(Set(requiredCards))
        
        for rank in uniqueRanks {
            var cardsNeeded: [String] = []
            for _ in 0..<neededCopies {
                cardsNeeded.append(rank)
            }
            
            possibleHands.append(
                PossibleHand(
                    handType: handType,
                    requiredCards: cardsNeeded,
                    probability: probability / Double(uniqueRanks.count)
                )
            )
        }
    }
    
    nonisolated private static func calculatePossibleHands(playerCards: [PlayingCard], communityCards: [PlayingCard]) -> [CombinedPossibleHands] {
        let validPlayerCards = playerCards.filter { $0.suit != nil && $0.rank != nil }
        let validCommunityCards = communityCards.filter { $0.suit != nil && $0.rank != nil }
        guard validPlayerCards.count >= 2 && validCommunityCards.count >= 3 else { return [] }
        var possibleHands: [PossibleHand] = []
        let allCards = validPlayerCards + validCommunityCards
        let cardsNeeded = 7 - allCards.count
        let holeRanks = validPlayerCards.compactMap { $0.rank }
        let cardsToSee = cardsNeeded
        let suits = allCards.compactMap { $0.suit }
        let ranks = allCards.compactMap { $0.rank }
        let suitCounts = Dictionary(grouping: suits, by: { $0 }).mapValues { $0.count }
        let rankCounts = Dictionary(grouping: ranks, by: { $0 }).mapValues { $0.count }

        // Current hand and tie-break vector for beating comparisons
        let currentHand = evaluateHand(cards: allCards)
        let currentVector: [Int] = {
            if let type = currentHand { return handTieBreakVector(for: type, with: allCards) }
            return []
        }()


        // Example (flush draw block) — apply the "skip if current already >= flush" rule before appending:
        for suit in Suit.allCases {
            guard let count = suitCounts[suit] else { continue }
            if count >= 5 { continue }
            if count == 4 && cardsToSee >= 1 {
                // Skip if current hand is already flush-or-stronger
                if let ch = currentHand, ch.rank >= PokerHandType.flush.rank { /* do not add flush */ }
                else {
                    let p = calculateFlushProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetSuit: suit, currentHandType: currentHand, currentVector: currentVector)
                    if p > 0 {
                        appendPossibleHands(to: &possibleHands, handType: .flush, requiredCards: ["Any \(suitName(suit))"], probability: p, neededCopies: 1)
                    }
                }
            } else if count == 3 && cardsToSee >= 2 {
                if let ch = currentHand, ch.rank >= PokerHandType.flush.rank { /* skip */ }
                else {
                    let p = calculateFlushProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetSuit: suit, currentHandType: currentHand, currentVector: currentVector)
                    if p > 0 {
                        appendPossibleHands(to: &possibleHands, handType: .flush, requiredCards: ["Any \(suitName(suit))"], probability: p, neededCopies: 2)
                    }
                }
            }
        }

        // --- Straight draws (same skip pattern)
        if hasOpenEndedStraightDraw(ranks: ranks) && cardsToSee >= 1 {
            if !(currentHand != nil && currentHand!.rank >= PokerHandType.straight.rank) {
                let p = calculateStraightProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, currentHandType: currentHand, currentVector: currentVector)
                if p > 0 { appendPossibleHands(to: &possibleHands, handType: .straight, requiredCards: getStraightDrawCards(ranks: ranks), probability: p, neededCopies: 1) }
            }
        } else if hasGutshotStraightDraw(ranks: ranks) && cardsToSee >= 1 {
            if !(currentHand != nil && currentHand!.rank >= PokerHandType.straight.rank) {
                let p = calculateStraightProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, currentHandType: currentHand, currentVector: currentVector)
                if p > 0 { appendPossibleHands(to: &possibleHands, handType: .straight, requiredCards: getStraightDrawCards(ranks: ranks), probability: p, neededCopies: 1) }
            }
        }

        // --- Sets / Quads improvements
        for rank in Rank.allCases {
            guard let count = rankCounts[rank] else { continue }
            if count == 2 && cardsToSee >= 1 {
                // skip if current already >= threeOfAKind
                if let ch = currentHand, ch.rank >= PokerHandType.threeOfAKind.rank { continue }
                let p = calculateSetProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetRank: rank, currentHandType: currentHand, currentVector: currentVector)
                if p > 0 { appendPossibleHands(to: &possibleHands, handType: .threeOfAKind, requiredCards: [rankDisplay(rank)], probability: p, neededCopies: 1) }
            } else if count == 3 && cardsToSee >= 1 {
                // If count==3 we could improve to quads (or already have full house). Only consider quads here.
                if let ch = currentHand, ch.rank >= PokerHandType.fourOfAKind.rank { continue }
                let p = calculateQuadsProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetRank: rank, currentHandType: currentHand, currentVector: currentVector)
                if p > 0 { appendPossibleHands(to: &possibleHands, handType: .fourOfAKind, requiredCards: [rankDisplay(rank)], probability: p, neededCopies: 1) }
            }
        }
        
        // --- Full house potential
        let tripCount = rankCounts.values.filter { $0 == 3 }.count
        let pairCount = rankCounts.values.filter { $0 == 2 }.count

        if (tripCount >= 1 || pairCount >= 2) && cardsToSee >= 1 {
            // Skip if the player already has a full house or better
            if !(currentHand != nil && currentHand!.rank >= PokerHandType.fullHouse.rank) {

                // Build a helpful, specific list of ranks that would complete a full house.
                // Cases:
                // 1) If there are two (or more) pairs currently -> hitting one more card of either paired rank will make a full house.
                // 2) If there is at least one trip -> pairing any other existing rank will make a full house;
                //    prefer listing ranks that already exist (have at least 1 occurrence). If none, fallback to "Any pair".
                var requiredCardsForFullHouse: [String] = []

                if pairCount >= 2 {
                    // Collect ranks that currently have exactly 2 cards (the pair ranks)
                    let pairRanks = rankCounts.filter { $0.value == 2 }.map { $0.key }
                    requiredCardsForFullHouse = pairRanks.map { rankDisplay($0) } // e.g. ["K", "8"]
                } else if tripCount >= 1 {
                    // We have at least one trip: find ranks (other than the trip rank) that appear at least once;
                    // pairing any of those will form a full house.
                    if let tripRank = rankCounts.first(where: { $0.value == 3 })?.key {
                        // Candidate ranks are any ranks present in the current cards except the trip rank
                        let candidateRanks = rankCounts.filter { $0.key != tripRank && $0.value >= 1 }.map { $0.key }
                        if !candidateRanks.isEmpty {
                            requiredCardsForFullHouse = candidateRanks.map { rankDisplay($0) }
                        } else {
                            // No specific candidate ranks present (edge case) -> fallback to generic description
                            requiredCardsForFullHouse = ["Any pair"]
                        }
                    } else {
                        // Defensive fallback — should not happen because tripCount >= 1 implies a tripRank exists
                        requiredCardsForFullHouse = ["Any pair"]
                    }
                }

                // If somehow empty, fall back to generic
                if requiredCardsForFullHouse.isEmpty {
                    requiredCardsForFullHouse = ["Any pair"]
                }

                let p = calculateFullHouseProbabilityBeatingCurrent(
                    playerCards: validPlayerCards,
                    communityCards: validCommunityCards,
                    currentHandType: currentHand,
                    currentVector: currentVector
                )

                if p > 0 {
                    if pairCount >= 2 {
                        // Need one more card of any paired rank
                        appendPossibleHands(to: &possibleHands, handType: .fullHouse, requiredCards: requiredCardsForFullHouse, probability: p, neededCopies: 1)
                    } else if tripCount >= 1 {
                        // Need two more cards of any other rank
                        appendPossibleHands(to: &possibleHands, handType: .fullHouse, requiredCards: requiredCardsForFullHouse, probability: p, neededCopies: 2)
                    }
                }
            }
        }
        
        // --- Two Pair potential
        if cardsToSee >= 1 {
            // If we already have a pair on the board + hole, we can look for another
            // distinct rank that could pair up.
            let existingPairs = rankCounts.filter { $0.value >= 2 }.map { $0.key }
            
            // Only meaningful if we already have one pair (or a single pair involving hole cards)
            if existingPairs.count == 1 {
                let existingPairRank = existingPairs.first!
                
                // Possible ranks (excluding the rank we already paired) from our hole cards or board
                let candidateRanks = Set(holeRanks + ranks).subtracting([existingPairRank])
                
                if !candidateRanks.isEmpty {
                    // Skip if current hand is already twoPair or stronger
                    if currentHand == nil || currentHand!.rank < PokerHandType.twoPair.rank {
                        let p = calculateTwoPairProbabilityBeatingCurrent(
                            playerCards: validPlayerCards,
                            communityCards: validCommunityCards,
                            existingPairRank: existingPairRank,
                            candidateRanks: Array(candidateRanks),
                            currentHandType: currentHand,
                            currentVector: currentVector
                        )
                        if p > 0 {
                            let required = candidateRanks.map { rankDisplay($0) }
                            appendPossibleHands(to: &possibleHands, handType: .twoPair, requiredCards: required, probability: p, neededCopies: 1)
                        }
                    }
                }
            }
        }

        // --- One pair from hole cards (only if it would BEAT the current hand)
        if cardsToSee >= 1 {
            var onePairRequired: [String] = []
            var targetRanks: [Rank] = []
            for r in holeRanks {
                let countForRank = rankCounts[r] ?? 0
                if countForRank < 2 {
                    onePairRequired.append("Any \(rankDisplay(r))")
                    targetRanks.append(r)
                }
            }
            if !onePairRequired.isEmpty {
                // Skip entirely if current already >= onePair
                if currentHand == nil || currentHand!.rank < PokerHandType.onePair.rank {
                    let p = calculatePairProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetRanks: targetRanks, currentHandType: currentHand, currentVector: currentVector)
                    if p > 0 { 
                        let requiredRanks = targetRanks.map { rankDisplay($0) }
                        appendPossibleHands(to: &possibleHands, handType: .onePair, requiredCards: requiredRanks, probability: p, neededCopies: 1) 
                    }
                }
            }
        }
        if cardsToSee >= 2 {
            for r in holeRanks {
                let countForRank = rankCounts[r] ?? 0
                if countForRank == 1 {
                    let p = calculateTripsFromUnpairedProbabilityBeatingCurrent(playerCards: validPlayerCards, communityCards: validCommunityCards, targetRank: r, currentHandType: currentHand, currentVector: currentVector)
                    if p > 0 {
                        appendPossibleHands(to: &possibleHands, handType: .threeOfAKind, requiredCards: [rankDisplay(r)], probability: p, neededCopies: 2)
                    }
                }
            }
        }

        print("possibleHands: \(possibleHands)")

        let combinedHands = combinePossibleHands(possibleHands)
        print("combinedHands: \(combinedHands)")
        return combinedHands.sorted { lhs, rhs in
            if lhs.totalProbability != rhs.totalProbability { return lhs.totalProbability > rhs.totalProbability }
            return lhs.handType.rank > rhs.handType.rank
        }
    }
    
    /// Combines possible hands with the same hand type
    nonisolated private static func combinePossibleHands(_ hands: [PossibleHand]) -> [CombinedPossibleHands] {
        var handsByType: [PokerHandType: [PossibleHand]] = [:]
        
        // Group hands by type
        for hand in hands {
            if handsByType[hand.handType] == nil {
                handsByType[hand.handType] = []
            }
            handsByType[hand.handType]?.append(hand)
        }
        
        // Combine each group
        var combinedHands: [CombinedPossibleHands] = []
        for (handType, handsOfType) in handsByType {
            if handsOfType.isEmpty {
                continue
            }
            
            var combinedRequiredCards: [[String]] = []
            var combinedProbabilities: [Double] = []
            var totalProbability: Double = 0

            handsOfType.enumerated().forEach { (index, hand) in
                combinedRequiredCards.append(hand.requiredCards)
                combinedProbabilities.append(hand.probability)
                totalProbability += hand.probability
            }

            combinedHands.append(CombinedPossibleHands(
                handType: handType, requiredCombinations: combinedRequiredCards, probabilities: combinedProbabilities, totalProbability: totalProbability
            ))
        }
        
        return combinedHands
    }
    
    // MARK: - Straight Draw Detection
    
    nonisolated private static func hasOpenEndedStraightDraw(ranks: [Rank]) -> Bool {
        let values = Set(ranks.map { rankValue($0) }).sorted()
        guard values.count >= 4 else { return false }
        
        // Check for regular open-ended straight draws
        for i in 0..<(values.count - 3) {
            let sequence = values[i..<(i + 4)]
            if sequence.last! - sequence.first! == 3 {
                return true
            }
        }
        
        // Check for wheel open-ended draws (A-2-3-4 needs 5, or 2-3-4-5 needs A)
        let valueSet = Set(values)
        // A-2-3-4 (need 5)
        if valueSet.isSuperset(of: [0, 1, 2, 12]) { return true }
        // 2-3-4-5 (need A or 6 for wheel or regular straight)
        if valueSet.isSuperset(of: [0, 1, 2, 3]) { return true }
        
        return false
    }
    
    nonisolated private static func hasGutshotStraightDraw(ranks: [Rank]) -> Bool {
        let values = Set(ranks.map { rankValue($0) }).sorted()
        guard values.count >= 4 else { return false }
        
        // Check for gaps in 5-card sequences
        for start in 0...8 {
            let straightRange = start..<(start + 5)
            let matching = values.filter { straightRange.contains($0) }
            if matching.count == 4 {
                // Make sure they're not 4 consecutive (that would be open-ended)
                let sortedMatching = matching.sorted()
                var isConsecutive = true
                for i in 0..<(sortedMatching.count - 1) {
                    if sortedMatching[i+1] - sortedMatching[i] != 1 {
                        isConsecutive = false
                        break
                    }
                }
                if !isConsecutive {
                    return true
                }
            }
        }
        
        // Check for wheel gutshot draws
        // A-2-3-5 (need 4), A-2-4-5 (need 3), A-3-4-5 (need 2), 2-3-4-A (need 5 - but this is open-ended)
        let valueSet = Set(values)
        let wheelCombos = [
            [0, 1, 2, 3, 12], // Full wheel (shouldn't trigger)
            [0, 1, 2, 12],    // A-2-3-4 (open-ended, shouldn't trigger here)
            [0, 1, 3, 12],    // A-2-4-5 missing 3
            [0, 2, 3, 12],    // A-3-4-5 missing 2
            [1, 2, 3, 12]     // 2-3-4-A missing 5 (but this is part of open-ended check)
        ]
        
        for combo in wheelCombos {
            if combo.count == 4 && Set(combo).isSubset(of: valueSet) {
                let sortedCombo = combo.sorted()
                // Check it's not 4 consecutive
                var hasGap = false
                for i in 0..<(sortedCombo.count - 1) {
                    if sortedCombo[i+1] - sortedCombo[i] > 1 {
                        hasGap = true
                        break
                    }
                }
                if hasGap || (sortedCombo.contains(12) && sortedCombo.contains(0)) {
                    return true
                }
            }
        }
        
        return false
    }
    
    nonisolated private static func getStraightDrawCards(ranks: [Rank]) -> [String] {
        let values = Set(ranks.map { rankValue($0) })
        var neededCards: Set<Rank> = []
        
        // Check all possible straights
        for start in 0...9 {
            let straightValues = Set(start..<(start + 5))
            let missing = straightValues.subtracting(values)
            
            // If we're missing exactly 1 card, it's a draw
            if missing.count == 1 {
                let missingValue = missing.first!
                if let rank = rankFromValue(missingValue) {
                    neededCards.insert(rank)
                }
            }
        }
        
        // Check for wheel draws (A-2-3-4-5)
        let wheelValues: Set<Int> = [0, 1, 2, 3, 12] // 2,3,4,5,A
        let missingWheel = wheelValues.subtracting(values)
        if missingWheel.count == 1 {
            let missingValue = missingWheel.first!
            if let rank = rankFromValue(missingValue) {
                neededCards.insert(rank)
            }
        }
        
        // Convert to display strings
        return neededCards.sorted { rankValue($0) < rankValue($1) }
            .map { rankDisplay($0) }
    }
    
    nonisolated private static func rankFromValue(_ value: Int) -> Rank? {
        switch value {
        case 0: return .two
        case 1: return .three
        case 2: return .four
        case 3: return .five
        case 4: return .six
        case 5: return .seven
        case 6: return .eight
        case 7: return .nine
        case 8: return .ten
        case 9: return .jack
        case 10: return .queen
        case 11: return .king
        case 12: return .ace
        default: return nil
        }
    }
    
    /// Generates a full 52-card deck in consistent order
    nonisolated private static func generateFullDeck() -> [PlayingCard] {
        var deck: [PlayingCard] = []
        // Generate in consistent order: Spades, Hearts, Clubs, Diamonds
        // and 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A for each suit
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(PlayingCard(suit: suit, rank: rank))
            }
        }
        return deck
    }
    
    /// Builds a vector of integers representing the hand's tie-break ordering:
    /// hand-making card ranks first, then kickers as needed.
    nonisolated private static func handTieBreakVector(for type: PokerHandType, with fullHand: [PlayingCard]) -> [Int] {
        // Extract ranks and counts
        let ranks = fullHand.compactMap { $0.rank }
        let values = ranks.map { rankValue($0) }
        let counts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }

        func topKickers(excluding excluded: [Int], limit: Int) -> [Int] {
            return values.filter { !excluded.contains($0) }.sorted(by: >).prefix(limit).map { $0 }
        }

        switch type {
        case .royalFlush:
            // All royal flushes tie
            return [0]
        case .straightFlush, .straight:
            // Highest card in straight determines strength; handle wheel (A-2-3-4-5) as 5-high (value 3)
            let unique = Set(values)
            var bestHigh = -1
            // Check wheel
            if Set([12,0,1,2,3]).isSubset(of: unique) {
                bestHigh = max(bestHigh, 3)
            }
            for start in 0...8 { // high from 4 to 12
                let seq = Set(start...(start+4))
                if seq.isSubset(of: unique) { bestHigh = max(bestHigh, start+4) }
            }
            return [bestHigh]
        case .fourOfAKind:
            // Rank of quads, then kicker
            let quad = counts.first(where: { $0.value == 4 })?.key ?? -1
            let kicker = topKickers(excluding: [quad], limit: 1)
            return [quad] + kicker
        case .fullHouse:
            // Rank of trips then pair
            let trips = counts.filter { $0.value >= 3 }.map { $0.key }.sorted(by: >)
            let tripRank = trips.first ?? -1
            // Remove trip cards then find best pair from remaining counts (could be another trips acting as pair)
            var pairRank = -1
            let remaining = counts.filter { $0.key != tripRank }
            if let bestPair = remaining.filter({ $0.value >= 2 }).map({ $0.key }).sorted(by: >).first {
                pairRank = bestPair
            }
            return [tripRank, pairRank]
        case .flush:
            // Top five cards of the flush suit
            // Determine flush suit
            let suitCounts = Dictionary(grouping: fullHand.compactMap { $0.suit }, by: { $0 }).mapValues { $0.count }
            guard let suit = suitCounts.first(where: { $0.value >= 5 })?.key else { return values.sorted(by: >) }
            let suited = fullHand.filter { $0.suit == suit }.compactMap { $0.rank }.map { rankValue($0) }.sorted(by: >)
            return Array(suited.prefix(5))
        case .threeOfAKind:
            // Trips rank then two highest kickers
            let trip = counts.first(where: { $0.value == 3 })?.key ?? -1
            let kickers = topKickers(excluding: [trip], limit: 2)
            return [trip] + kickers
        case .twoPair:
            // Higher pair, lower pair, then kicker
            let pairs = counts.filter { $0.value == 2 }.map { $0.key }.sorted(by: >)
            let highPair = pairs.first ?? -1
            let lowPair = pairs.dropFirst().first ?? -1
            let kicker = topKickers(excluding: [highPair, lowPair], limit: 1)
            return [highPair, lowPair] + kicker
        case .onePair:
            // Pair rank, then three highest kickers
            let pair = counts.first(where: { $0.value == 2 })?.key ?? -1
            let kickers = topKickers(excluding: [pair], limit: 3)
            return [pair] + kickers
        case .highCard:
            // Top five cards
            return Array(values.sorted(by: >).prefix(5))
        }
    }
    
    // MARK: - Hand Comparison Helpers for Beating Current Hand
    
    nonisolated private static func beatsCurrentHand(candidateType: PokerHandType, candidateFullHand: [PlayingCard], currentHandType: PokerHandType?, currentVector: [Int]) -> Bool {
        // If there is no current hand, any candidate made hand beats it
        guard let currentType = currentHandType else { return true }
        if candidateType.rank > currentType.rank { return true }
        if candidateType.rank < currentType.rank { return false }
        // Same hand type: compare vectors
        let candidateVector = handTieBreakVector(for: candidateType, with: candidateFullHand)
        for i in 0..<min(candidateVector.count, currentVector.count) {
            if candidateVector[i] > currentVector[i] { return true }
            if candidateVector[i] < currentVector[i] { return false }
        }
        return false // tie does not beat
    }
    
    // MARK: - Monte Carlo Simulation
    
    /// Runs Monte Carlo simulation to calculate probability
    /// - Parameters:
    ///   - playerCards: Player's hole cards
    ///   - communityCards: Current community cards
    ///   - test: Boolean function to test each simulation
    /// - Returns: Probability (0.0 to 1.0) of the test condition being true
    nonisolated private static func runSimulation(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        test: ([PlayingCard]) -> Bool
    ) -> Double {
        let remainingDeck = getRemainingDeck(playerCards: playerCards, communityCards: communityCards)
        let cardsNeeded = 5 - communityCards.count // How many community cards to complete
        
        guard cardsNeeded > 0 && cardsNeeded <= remainingDeck.count else {
            // No simulation needed if all cards revealed
            return 0.0
        }
        
        var successCount = 0
        
        for _ in 0..<simulationCount {
            // Randomly select cards to complete the community cards
            let shuffledDeck = remainingDeck.shuffled()
            let simulatedCommunityCards = communityCards + Array(shuffledDeck.prefix(cardsNeeded))
            
            // Test the condition
            if test(simulatedCommunityCards) {
                successCount += 1
            }
        }
        
        return Double(successCount) / Double(simulationCount)
    }
    
    /// Runs Monte Carlo simulation to calculate opponent win probability
    /// - Parameters:
    ///   - playerCards: Player's hole cards
    ///   - communityCards: Current community cards
    ///   - test: Boolean function that takes opponent cards and simulated community cards
    /// - Returns: Probability (0.0 to 1.0) of the test condition being true
    nonisolated private static func runOpponentSimulation(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        test: ([PlayingCard], [PlayingCard]) -> Bool
    ) -> Double {
        let remainingDeck = getRemainingDeck(playerCards: playerCards, communityCards: communityCards)
        let cardsNeeded = 5 - communityCards.count // How many community cards to complete
        
        var successCount = 0
        var totalSimulations = 0
        
        for _ in 0..<simulationCount {
            // Shuffle deck for this simulation
            let shuffledDeck = remainingDeck.shuffled()
            
            // Select opponent hole cards (first 2 cards)
            guard shuffledDeck.count >= 2 + cardsNeeded else { continue }
            let opponentCards = Array(shuffledDeck.prefix(2))
            
            // Complete community cards if needed
            let simulatedCommunityCards: [PlayingCard]
            if cardsNeeded > 0 {
                simulatedCommunityCards = communityCards + Array(shuffledDeck[2..<(2 + cardsNeeded)])
            } else {
                simulatedCommunityCards = communityCards
            }
            
            // Test the condition
            if test(opponentCards, simulatedCommunityCards) {
                successCount += 1
            }
            totalSimulations += 1
        }
        
        guard totalSimulations > 0 else { return 0.0 }
        return Double(successCount) / Double(totalSimulations)
    }
    
    // MARK: - Probability Calculations (using Monte Carlo simulation)
    // --- Monte-Carlo helpers: require exact hand type matches
    // Replace the bodies of the helpers with these corrected versions:

    nonisolated private static func calculateFlushProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], targetSuit: Suit, currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let suitCount = allCards.filter { $0.suit == targetSuit }.count
            guard suitCount >= 5 else { return false }
            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // require exact flush (not straightFlush / royalFlush)
            guard candidateType == .flush else { return false }            // <- changed: exact match
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    nonisolated private static func calculateStraightProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let ranks = allCards.compactMap { $0.rank }
            guard checkStraight(ranks: ranks) else { return false }
            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // require exact straight (not straightFlush or royalFlush)
            guard candidateType == .straight else { return false }         // <- changed: exact match
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    nonisolated private static func calculateSetProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], targetRank: Rank, currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCount = allCards.filter { $0.rank == targetRank }.count
            guard rankCount >= 3 else { return false }
            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // require exact threeOfAKind (not full house / quads)
            guard candidateType == .threeOfAKind else { return false }     // <- changed
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    nonisolated private static func calculateQuadsProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], targetRank: Rank, currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCount = allCards.filter { $0.rank == targetRank }.count
            guard rankCount >= 4 else { return false }
            guard let candidateType = evaluateHand(cards: allCards), candidateType == .fourOfAKind else { return false }
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    nonisolated private static func calculatePairProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], targetRanks: [Rank], currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCounts = Dictionary(grouping: allCards.compactMap { $0.rank }, by: { $0 }).mapValues { $0.count }
            // must form a pair of exactly one of the target ranks
            let hasTargetPair = targetRanks.contains { rank in (rankCounts[rank] ?? 0) >= 2 }
            guard hasTargetPair else { return false }
            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // require exact onePair (not twoPair / trips / full etc.)
            guard candidateType == .onePair else { return false }         // <- changed
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }
    
    nonisolated private static func calculateTwoPairProbabilityBeatingCurrent(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        existingPairRank: Rank,
        candidateRanks: [Rank],
        currentHandType: PokerHandType?,
        currentVector: [Int]
    ) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCounts = Dictionary(grouping: allCards.compactMap { $0.rank }, by: { $0 }).mapValues { $0.count }

            // Require that we still have the original pair rank,
            // and that at least one *different* rank also forms a pair.
            guard let existingPairCount = rankCounts[existingPairRank], existingPairCount >= 2 else { return false }
            let hasNewPair = candidateRanks.contains { rankCounts[$0] ?? 0 >= 2 }
            guard hasNewPair else { return false }

            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // Require exact Two Pair (not Full House or better)
            guard candidateType == .twoPair else { return false }

            return beatsCurrentHand(
                candidateType: candidateType,
                candidateFullHand: allCards,
                currentHandType: currentHandType,
                currentVector: currentVector
            )
        }
    }


    nonisolated private static func calculateTripsFromUnpairedProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], targetRank: Rank, currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCount = allCards.filter { $0.rank == targetRank }.count
            guard rankCount >= 3 else { return false }
            guard let candidateType = evaluateHand(cards: allCards) else { return false }
            // require exact threeOfAKind (not full house)
            guard candidateType == .threeOfAKind else { return false }    // <- changed
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    nonisolated private static func calculateFullHouseProbabilityBeatingCurrent(playerCards: [PlayingCard], communityCards: [PlayingCard], currentHandType: PokerHandType?, currentVector: [Int]) -> Double {
        return runSimulation(playerCards: playerCards, communityCards: communityCards) { simulatedCommunity in
            let allCards = playerCards + simulatedCommunity
            let rankCounts = Dictionary(grouping: allCards.compactMap { $0.rank }, by: { $0 }).mapValues { $0.count }
            let counts = rankCounts.values.sorted(by: >)
            guard counts.count >= 2 && counts[0] >= 3 && counts[1] >= 2 else { return false }
            guard let candidateType = evaluateHand(cards: allCards), candidateType == .fullHouse else { return false } // <- changed: exact fullHouse required
            return beatsCurrentHand(candidateType: candidateType, candidateFullHand: allCards, currentHandType: currentHandType, currentVector: currentVector)
        }
    }

    /// Get remaining deck excluding used cards
    nonisolated private static func getRemainingDeck(playerCards: [PlayingCard], communityCards: [PlayingCard]) -> [PlayingCard] {
        let allPossibleCards = generateFullDeck()
        let usedCards = playerCards + communityCards
        
        return allPossibleCards.filter { possibleCard in
            !usedCards.contains { usedCard in
                possibleCard.suit == usedCard.suit && possibleCard.rank == usedCard.rank
            }
        }
    }
    // MARK: - Opponent Hand Analysis
    
    /// Generates a unique cache key for the current game state
    nonisolated private static func generateCacheKey(playerCards: [PlayingCard], communityCards: [PlayingCard], opponentHands: [[PlayingCard]] = []) -> String {
        let allCards = playerCards + communityCards
        let cardStrings = allCards.map { card in
            guard let suit = card.suit, let rank = card.rank else { return "empty" }
            return "\(rank.rawValue)\(suit.rawValue)"
        }
        
        let opponentStrings = opponentHands.map { hand in
            hand.map { card in
                guard let suit = card.suit, let rank = card.rank else { return "empty" }
                return "\(rank.rawValue)\(suit.rawValue)"
            }.joined(separator: ",")
        }
        
        let opponentPart = opponentStrings.isEmpty ? "" : "|opponents:" + opponentStrings.joined(separator: ";")
        return cardStrings.joined(separator: "-") + opponentPart
    }
    
    /// Calculates win probability asynchronously (runs in background)
    static func calculateWinProbabilityAsync(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        opponentHands: [[PlayingCard]] = []
    ) async -> (playerWinProbability: Double, opponentWinProbabilities: [Double]) {
        return await Task.detached(priority: .userInitiated) {
            let validPlayerCards = playerCards.filter { $0.suit != nil && $0.rank != nil }
            let validCommunityCards = communityCards.filter { $0.suit != nil && $0.rank != nil }
            let validOpponentHands = opponentHands.map { hand in
                hand.filter { $0.suit != nil && $0.rank != nil }
            }.filter { !$0.isEmpty }
            
            let allCards = validPlayerCards + validCommunityCards
            let currentHand = evaluateHand(cards: allCards)
            
            if validOpponentHands.isEmpty {
                // No opponents - use original calculation
                let playerWinProbability = estimateWinProbability(
                    playerCards: validPlayerCards,
                    communityCards: validCommunityCards,
                    currentHand: currentHand
                )
                return (playerWinProbability, [])
            } else {
                // With opponents - calculate multi-player win probabilities
                return calculateMultiPlayerWinProbabilities(
                    playerCards: validPlayerCards,
                    communityCards: validCommunityCards,
                    opponentHands: validOpponentHands,
                    currentHand: currentHand
                )
            }
        }.value
    }
    
    /// Analyzes possible hands asynchronously (runs in background)
    static func analyzePossibleHandsAsync(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        opponentHands: [[PlayingCard]] = []
    ) async -> [CombinedPossibleHands] {
        return await Task.detached(priority: .userInitiated) {
            return calculatePossibleHands(
                playerCards: playerCards,
                communityCards: communityCards
            )
        }.value
    }
    
    /// Analyzes opponent hands asynchronously (runs in background)
    static func analyzeOpponentHandsAsync(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        currentHand: PokerHandType?,
        opponentHands: [[PlayingCard]] = []
    ) async -> [OpponentHand] {
        return await Task.detached(priority: .userInitiated) {
            return analyzeOpponentHands(
                playerCards: playerCards,
                communityCards: communityCards,
                currentHand: currentHand
            )
        }.value
    }
    
    /// Analyzes what hands opponents could have that beat the player using Monte Carlo simulation
    nonisolated private static func analyzeOpponentHands(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        currentHand: PokerHandType?
    ) -> [OpponentHand] {
        
        // Get remaining deck using helper function
        let remainingDeck = getRemainingDeck(playerCards: playerCards, communityCards: communityCards)
        guard !remainingDeck.isEmpty else { return [] }
        
        let cardsNeeded = 5 - communityCards.count
        
        // Dictionary to track opponent hand types and example combinations
        var handTypeOccurrences: [PokerHandType: Int] = [:]
        var handTypeExamples: [PokerHandType: [(card1: PlayingCard, card2: PlayingCard)]] = [:]
        
        // Run Monte Carlo simulations
        for _ in 0..<simulationCount {
            let shuffledDeck = remainingDeck.shuffled()
            
            // Select opponent hole cards (first 2 cards)
            guard shuffledDeck.count >= 2 + cardsNeeded else { continue }
            let opponentHoleCards = Array(shuffledDeck.prefix(2))
            
            // Complete community cards if needed
            let simulatedCommunityCards: [PlayingCard]
            if cardsNeeded > 0 {
                simulatedCommunityCards = communityCards + Array(shuffledDeck[2..<(2 + cardsNeeded)])
            } else {
                simulatedCommunityCards = communityCards
            }
            
            let playerFullHand = playerCards + simulatedCommunityCards
            let opponentFullHand = opponentHoleCards + simulatedCommunityCards
            
            // Evaluate hands
            guard let opponentHandType = evaluateHand(cards: opponentFullHand) else {
                continue
            }
            
            let playerHand = evaluateHand(cards: playerFullHand)
            
            // Check if opponent beats player
            var beatsPlayer: Bool = false
            if let playerHandType = playerHand {
                if opponentHandType.rank > playerHandType.rank {
                    beatsPlayer = true
                } else if opponentHandType.rank == playerHandType.rank {
                    // Use tie break vector comparison
                    let playerVector = handTieBreakVector(for: playerHandType, with: playerFullHand)
                    let opponentVector = handTieBreakVector(for: opponentHandType, with: opponentFullHand)
                    for k in 0..<min(playerVector.count, opponentVector.count) {
                        if opponentVector[k] > playerVector[k] {
                            beatsPlayer = true
                            break
                        } else if opponentVector[k] < playerVector[k] {
                            break
                        }
                    }
                }
            } else {
                beatsPlayer = true  // Any hand beats no hand
            }
            
            if beatsPlayer {
                // Track occurrence
                handTypeOccurrences[opponentHandType, default: 0] += 1
                
                // Store example combinations
                if handTypeExamples[opponentHandType] == nil {
                    handTypeExamples[opponentHandType] = []
                }
                if handTypeExamples[opponentHandType]!.count < 10 { // Store up to 10 examples
                    handTypeExamples[opponentHandType]!.append((opponentHoleCards[0], opponentHoleCards[1]))
                }
            }
        }
        
        // Convert to OpponentHand objects
        var opponentHands: [OpponentHand] = []
        
        for (handType, occurrences) in handTypeOccurrences {
            guard occurrences > 0 else { continue }
            
            // Calculate probability from simulation results
            let probability = Double(occurrences) / Double(simulationCount)
            
            // Select the best example from stored examples
            guard let examples = handTypeExamples[handType],
                  !examples.isEmpty else {
                continue
            }
            
            let bestExample = selectBestExample(
                combinations: examples,
                communityCards: communityCards
            )
            
            guard let exampleCombo = bestExample,
                  let rank1 = exampleCombo.card1.rank,
                  let suit1 = exampleCombo.card1.suit,
                  let rank2 = exampleCombo.card2.rank,
                  let suit2 = exampleCombo.card2.suit else {
                continue
            }
            
            let opponentHand = OpponentHand(
                handType: handType,
                exampleHoleCards: [
                    (rank1, suit1),
                    (rank2, suit2)
                ],
                combinations: occurrences, // Number of times this hand occurred in simulations
                probability: probability
            )
            
            opponentHands.append(opponentHand)
        }
        
        // Sort by probability (highest first), then by hand strength
        return opponentHands.sorted { lhs, rhs in
            if lhs.probability != rhs.probability {
                return lhs.probability > rhs.probability
            }
            return lhs.handType.rank > rhs.handType.rank
        }
    }
    
    /// Selects the best example from combinations (highest ranking hole cards)
    nonisolated private static func selectBestExample(
        combinations: [(card1: PlayingCard, card2: PlayingCard)],
        communityCards: [PlayingCard]
    ) -> (card1: PlayingCard, card2: PlayingCard)? {
        guard !combinations.isEmpty else { return nil }
        
        // Evaluate and sort combinations by hand strength
        let sortedCombinations = combinations.sorted { combo1, combo2 in
            let hand1 = [combo1.card1, combo1.card2] + communityCards
            let hand2 = [combo2.card1, combo2.card2] + communityCards
            
            guard let handType1 = evaluateHand(cards: hand1),
                  let handType2 = evaluateHand(cards: hand2) else {
                return false
            }
            
            // First compare by hand type rank
            if handType1.rank != handType2.rank {
                return handType1.rank > handType2.rank
            }
            
            // If same hand type, compare by handTieBreakVector on full 7-card hands
            let vector1 = handTieBreakVector(for: handType1, with: hand1)
            let vector2 = handTieBreakVector(for: handType2, with: hand2)
            for i in 0..<min(vector1.count, vector2.count) {
                if vector1[i] != vector2[i] {
                    return vector1[i] > vector2[i]
                }
            }
            return false
        }
        
        return sortedCombinations.first
    }

    
    
    /// Calculates win probabilities for all players in a multi-player game
    nonisolated private static func calculateMultiPlayerWinProbabilities(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        opponentHands: [[PlayingCard]],
        currentHand: PokerHandType?
    ) -> (playerWinProbability: Double, opponentWinProbabilities: [Double]) {
        let allPlayers = [playerCards] + opponentHands
        var playerWinCounts = Array(repeating: 0, count: allPlayers.count)
        var totalSimulations = 0
        
        // Run Monte Carlo simulation
        for _ in 0..<simulationCount {
            let remainingDeck = getRemainingDeck(playerCards: playerCards, communityCards: communityCards)
            let cardsNeeded = 5 - communityCards.count
            
            guard cardsNeeded > 0 && cardsNeeded <= remainingDeck.count else {
                // All community cards are known - evaluate directly
                let results = evaluateAllPlayerHands(allPlayers: allPlayers, communityCards: communityCards)
                if let winnerIndex = findWinner(results: results) {
                    playerWinCounts[winnerIndex] += 1
                    totalSimulations += 1
                }
                continue
            }
            
            // Shuffle deck and complete community cards
            let shuffledDeck = remainingDeck.shuffled()
            let simulatedCommunityCards = communityCards + Array(shuffledDeck.prefix(cardsNeeded))
            
            let results = evaluateAllPlayerHands(allPlayers: allPlayers, communityCards: simulatedCommunityCards)
            if let winnerIndex = findWinner(results: results) {
                playerWinCounts[winnerIndex] += 1
                totalSimulations += 1
            }
        }
        
        guard totalSimulations > 0 else {
            return (0.0, Array(repeating: 0.0, count: opponentHands.count))
        }
        
        let playerWinProbability = Double(playerWinCounts[0]) / Double(totalSimulations)
        let opponentWinProbabilities = Array(playerWinCounts[1...]).map { Double($0) / Double(totalSimulations) }
        
        return (playerWinProbability, opponentWinProbabilities)
    }
    
    /// Evaluates all player hands with given community cards
    nonisolated private static func evaluateAllPlayerHands(allPlayers: [[PlayingCard]], communityCards: [PlayingCard]) -> [(handType: PokerHandType?, tieBreakVector: [Int])] {
        return allPlayers.map { playerCards in
            let fullHand = playerCards + communityCards
            let handType = evaluateHand(cards: fullHand)
            let tieBreakVector = handType != nil ? handTieBreakVector(for: handType!, with: fullHand) : []
            return (handType, tieBreakVector)
        }
    }
    
    /// Finds the winner among all players
    nonisolated private static func findWinner(results: [(handType: PokerHandType?, tieBreakVector: [Int])]) -> Int? {
        var bestPlayerIndex: Int?
        var bestHandType: PokerHandType?
        var bestTieBreakVector: [Int] = []
        
        for (index, result) in results.enumerated() {
            let (handType, tieBreakVector) = result
            
            // Skip players with no hand
            guard let currentHandType = handType else { continue }
            
            // First player with a hand
            if bestPlayerIndex == nil {
                bestPlayerIndex = index
                bestHandType = currentHandType
                bestTieBreakVector = tieBreakVector
                continue
            }
            
            // Compare with current best
            if currentHandType.rank > bestHandType!.rank {
                // Current player has better hand type
                bestPlayerIndex = index
                bestHandType = currentHandType
                bestTieBreakVector = tieBreakVector
            } else if currentHandType.rank == bestHandType!.rank {
                // Same hand type - compare tie break vectors
                for i in 0..<min(tieBreakVector.count, bestTieBreakVector.count) {
                    if tieBreakVector[i] > bestTieBreakVector[i] {
                        bestPlayerIndex = index
                        bestHandType = currentHandType
                        bestTieBreakVector = tieBreakVector
                        break
                    } else if tieBreakVector[i] < bestTieBreakVector[i] {
                        break
                    }
                }
            }
        }
        
        return bestPlayerIndex
    }
    
    nonisolated private static func estimateWinProbability(
        playerCards: [PlayingCard],
        communityCards: [PlayingCard],
        currentHand: PokerHandType?
    ) -> Double {
        // Use Monte Carlo simulation for win probability
        return runOpponentSimulation(playerCards: playerCards, communityCards: communityCards) { opponentCards, simulatedCommunity in
            let playerFullHand = playerCards + simulatedCommunity
            let opponentFullHand = opponentCards + simulatedCommunity
            
            let playerHand = evaluateHand(cards: playerFullHand)
            let opponentHand = evaluateHand(cards: opponentFullHand)
            
            // Compare hands
            if let playerHandType = playerHand, let opponentHandType = opponentHand {
                if playerHandType.rank > opponentHandType.rank {
                    return true // Player wins
                } else if playerHandType.rank == opponentHandType.rank {
                    // Same hand type, compare using hand-causing cards first, then kickers
                    let playerVector = handTieBreakVector(for: playerHandType, with: playerFullHand)
                    let opponentVector = handTieBreakVector(for: opponentHandType, with: opponentFullHand)
                    for i in 0..<min(playerVector.count, opponentVector.count) {
                        if playerVector[i] > opponentVector[i] { return true }
                        if playerVector[i] < opponentVector[i] { return false }
                    }
                    return false // Tie counts as loss for conservative estimate
                }
            } else if playerHand != nil && opponentHand == nil {
                return true // Player wins
            }
            
            return false // Opponent wins or tie
        }
    }
    
}
