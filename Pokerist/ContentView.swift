//
//  ContentView.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()
    
    private func getCurrentHand() -> PokerHandType? {
        let validPlayerCards = gameState.playerCards.filter { $0.suit != nil && $0.rank != nil }
        let validCommunityCards = gameState.communityCards.filter { $0.suit != nil && $0.rank != nil }
        
        guard validPlayerCards.count >= 2 else { return nil }
        
        let allCards = validPlayerCards + validCommunityCards
        return PokerHandAnalyzer.evaluateHand(cards: allCards)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.leading, -20)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("Pokerist")
                        .font(Font.largeTitle.bold())
                        .padding(.leading, -15)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Label("Your Cards", systemImage: "hand.draw.fill")
                        .font(Font.title.bold())
                    
                    Spacer()
                    
                    // Current Hand Badge
                    if let currentHand = getCurrentHand() {
                        CurrentHandBadge(handType: currentHand)
                    }
                }
                .padding(.horizontal)
                
                YourHandSection(gameState: gameState)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                HStack {
                    Label("Community Cards", systemImage: "person.2.arrow.trianglehead.counterclockwise")
                        .font(Font.title.bold())
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                CommunityCardsSection(gameState: gameState)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                InformationSection(gameState: gameState)
                
                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
