//
//  RequiredCardsView.swift
//  Pokerist
//
//  Created by Kerem Kirici on 5.10.2025.
//

import SwiftUI


// MARK: - Required Cards View
struct RequiredCardsView: View {
    let requiredCards: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(requiredCards, id: \.self) { cardString in
                
                if let cardView = parseCardString(cardString) {
                    cardView
                } else {
                    // Fallback to text if can't parse
                    Text(cardString)
                        .font(.caption)
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.15))
                        )
                }
                
            }
        }
    }
    
    private func parseCardString(_ string: String) -> AnyView? {
        let lowercased = string.lowercased()
        
        // Check for suit patterns
        if lowercased.contains("heart") {
            return AnyView(CardView(suit: .heart).xsmall())
        } else if lowercased.contains("spade") {
            return AnyView(CardView(suit: .spade).xsmall())
        } else if lowercased.contains("club") {
            return AnyView(CardView(suit: .club).xsmall())
        } else if lowercased.contains("diamond") {
            return AnyView(CardView(suit: .diamond).xsmall())
        }
        
        // Check for rank patterns
        for rank in Rank.allCases {
            if lowercased.contains(rank.display.lowercased()) || lowercased.contains(rank.accessibility.lowercased()) {
                return AnyView(CardView(rank: rank).xsmall())
            }
        }
        
        // Check for generic "any pair", "completing card" etc
        if lowercased.contains("pair") {
            return AnyView(
                HStack(spacing: 3) {
                    CardView(mode: .empty).xsmall()
                    CardView(mode: .empty).xsmall()
                }
            )
        } else if lowercased.contains("completing") || lowercased.contains("any") {
            return AnyView(CardView(mode: .empty).xsmall())
        }
        
        return nil
    }
}
