//
//  WinProbabilityCard.swift
//  Pokerist
//
//  Created by Kerem Kirici on 5.10.2025.
//

import SwiftUI

struct WinProbabilityCard: View {
    let probability: Double?  // Nil when async loading needed
    let currentHand: PokerHandType?
    let canExpand: Bool  // Whether there are enough cards to show expanded content
    let cacheKey: String
    let playerCards: [PlayingCard]
    let communityCards: [PlayingCard]
    
    @Binding var isExpanded: Bool
    @State private var expandedHandIds: Set<UUID> = []  // Track which hands are expanded
    @State private var winProbabilityState: WinProbabilityState = .notLoaded
    @State private var opponentHandsState: OpponentHandsState = .notLoaded
    @State private var winProbabilityTask: Task<Void, Never>?
    @State private var opponentHandsTask: Task<Void, Never>?
    
    private let analyzer = PokerHandAnalyzer.self
    
    // Cache for results
    @State private static var winProbabilityCache: [String: Double] = [:]
    @State private static var opponentHandsCache: [String: [OpponentHand]] = [:]
    
    enum WinProbabilityState {
        case notLoaded
        case loading
        case loaded(Double)
        case error
    }
    
    enum OpponentHandsState {
        case notLoaded
        case loading
        case loaded([OpponentHand])
        case error
    }
    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleExpansion) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Win Probability")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if canExpand {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("Based on \(analyzer.simulationCount.formatted()) simulations")
                            .font(.caption2)
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    
                    // Show probability or loading indicator
                    switch winProbabilityState {
                    case .notLoaded, .loading:
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Calculating...")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                    case .loaded(let calculatedProbability):
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            ProbabilityText(probability: calculatedProbability)
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(probabilityColor(for: calculatedProbability))
                            
                            Spacer()
                            
                            // Visual indicator
                            ProbabilityMeter(value: calculatedProbability)
                        }
                        
                    case .error:
                        Text("Error calculating")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expanded content (only if expansion is allowed and expanded)
            if canExpand && isExpanded {
                Divider()
                
                switch opponentHandsState {
                case .notLoaded:
                    // Should not happen, but show loading
                    LoadingView()
                    
                case .loading:
                    LoadingView()
                    
                case .loaded(let opponentHands):
                    if opponentHands.isEmpty {
                        EmptyOpponentHandsView()
                    } else {
                        OpponentHandsListView(
                            opponentHands: opponentHands,
                            currentHand: currentHand,
                            expandedHandIds: $expandedHandIds
                        )
                    }
                    
                case .error:
                    ErrorView()
                }
            }
        }
        .padding()
        .background(
            ZStack {
                // Liquid glass effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                borderColor.opacity(0.1),
                                borderColor.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor.opacity(0.3), lineWidth: 1.5)
                
                // Inner glow
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.5)
            }
        )
        .onAppear {
            loadWinProbabilityIfNeeded()
        }
    }
    
    private var borderColor: Color {
        switch winProbabilityState {
        case .loaded(let p):
            return probabilityColor(for: p)
        case .error:
            return .red
        case .notLoaded, .loading:
            return .secondary
        }
    }
    
    // MARK: - Helper Functions
    
    private func probabilityColor(for prob: Double) -> Color {
        switch prob {
        case 0.7...1.0: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
    
    private func toggleExpansion() {
        if canExpand {
            let willExpand = !isExpanded
            
            if willExpand {
                // Set loading state immediately (synchronously) before animation
                opponentHandsState = .loading
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
            
            // Load opponent hands when expanding
            if willExpand {
                loadOpponentHandsIfNeeded()
            } else {
                // Cancel calculation if collapsing
                opponentHandsTask?.cancel()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadWinProbabilityIfNeeded() {
        // Cancel any existing task
        winProbabilityTask?.cancel()
        
        // Check if already loaded or provided
        if case .loaded = winProbabilityState {
            return
        }
        
        // Check cache first
        if let cached = Self.winProbabilityCache[cacheKey] {
            winProbabilityState = .loaded(cached)
            return
        }
        
        // Set loading state
        winProbabilityState = .loading
        
        // Start async calculation
        winProbabilityTask = Task { @MainActor in
            do {
                // Small delay for smooth UI
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                guard !Task.isCancelled else { return }
                
                // Run calculation in background
                let calculatedProbability = await PokerHandAnalyzer.calculateWinProbabilityAsync(
                    playerCards: playerCards,
                    communityCards: communityCards
                )
                
                guard !Task.isCancelled else { return }
                
                // Cache the result
                Self.winProbabilityCache[cacheKey] = calculatedProbability
                
                // Update state
                winProbabilityState = .loaded(calculatedProbability)
            } catch {
                winProbabilityState = .error
            }
        }
    }
    
    private func loadOpponentHandsIfNeeded() {
        // Cancel any existing task
        opponentHandsTask?.cancel()
        
        // Check cache first
        if let cached = Self.opponentHandsCache[cacheKey] {
            // Wait for expansion animation (0.4s) + buffer for loading animation
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                guard !Task.isCancelled else { return }
                opponentHandsState = .loaded(cached)
            }
            return
        }
        
        // Wait for expansion animation to complete + loading animation to be visible
        opponentHandsTask = Task { @MainActor in
            do {
                // Wait for expansion animation (0.4s spring) + loading animation buffer
                // This ensures user sees the loading state and animation is smooth
                try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                
                // Check if task was cancelled during delay
                guard !Task.isCancelled else { return }
                
                // Run calculation in background
                let hands = await PokerHandAnalyzer.analyzeOpponentHandsAsync(
                    playerCards: playerCards,
                    communityCards: communityCards,
                    currentHand: currentHand
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                // Cache the results
                Self.opponentHandsCache[cacheKey] = hands
                
                // Update state (already on MainActor)
                opponentHandsState = .loaded(hands)
            } catch {
                opponentHandsState = .error
            }
        }
    }
    
    func resetForNewCards() {
        // Close expansion and reset state
        isExpanded = false
        winProbabilityState = .notLoaded
        opponentHandsState = .notLoaded
        expandedHandIds.removeAll()
        winProbabilityTask?.cancel()
        opponentHandsTask?.cancel()
    }
    
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Analyzing opponent hands...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - Empty View
private struct EmptyOpponentHandsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            Text("No opponent hands can pratically beat you!")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Error View
private struct ErrorView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
            Text("Failed to analyze opponent hands")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Opponent Hands List View
private struct OpponentHandsListView: View {
    let opponentHands: [OpponentHand]
    let currentHand: PokerHandType?
    @Binding var expandedHandIds: Set<UUID>
    
    private let analyzer = PokerHandAnalyzer.self
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentHand != nil ? "Hands That Beat You:" : "All Possible Hands:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Combos estimated from \(analyzer.simulationCount.formatted()) simulations")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
            ForEach(opponentHands.prefix(8)) { opponentHand in
                ExpandableOpponentHandRow(
                    opponentHand: opponentHand,
                    isExpanded: expandedHandIds.contains(opponentHand.id)
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if expandedHandIds.contains(opponentHand.id) {
                            expandedHandIds.remove(opponentHand.id)
                        } else {
                            expandedHandIds.insert(opponentHand.id)
                        }
                    }
                }
                
                if opponentHand.id != opponentHands.prefix(8).last?.id {
                    Divider()
                        .padding(.leading, 28)
                }
            }
            
            if opponentHands.count > 8 {
                Text("+ \(opponentHands.count - 8) more hand types")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 28)
            }
        }
    }
}

// MARK: - Expandable Opponent Hand Row
private struct ExpandableOpponentHandRow: View {
    let opponentHand: OpponentHand
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 8) {
                // Main row: Hand type, probability, and chevron
                HStack(spacing: 8) {
                    Image(systemName: opponentHand.handType.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red.opacity(0.8))
                        .frame(width: 20)
                    
                    Text(opponentHand.handType.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    ProbabilityText(probability: opponentHand.probability)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.15))
                        )
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                // Expanded content: Example hole cards
                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        Divider()
                            .padding(.leading, 28)
                        
                        HStack(spacing: 6) {
                            Text("Example:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ForEach(0..<opponentHand.exampleHoleCards.count, id: \.self) { index in
                                let (rank, suit) = opponentHand.exampleHoleCards[index]
                                CardView(suit: suit, rank: rank)
                                    .xsmall()
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 28)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Not expanded
        WinProbabilityCard(
            probability: 0.72,
            currentHand: .onePair,
            canExpand: true,
            cacheKey: "preview1",
            playerCards: [
                PlayingCard(suit: .heart, rank: .ace),
                PlayingCard(suit: .spade, rank: .ace)
            ],
            communityCards: [
                PlayingCard(suit: .club, rank: .king),
                PlayingCard(suit: .diamond, rank: .queen),
                PlayingCard(suit: .heart, rank: .jack)
            ],
            isExpanded: .constant(false)
        )
        
        // Expanded
        WinProbabilityCard(
            probability: 0.45,
            currentHand: .twoPair,
            canExpand: true,
            cacheKey: "preview2",
            playerCards: [
                PlayingCard(suit: .heart, rank: .king),
                PlayingCard(suit: .spade, rank: .queen)
            ],
            communityCards: [
                PlayingCard(suit: .club, rank: .king),
                PlayingCard(suit: .diamond, rank: .queen),
                PlayingCard(suit: .heart, rank: .five),
                PlayingCard(suit: .spade, rank: .two),
                PlayingCard(suit: .club, rank: .nine)
            ],
            isExpanded: .constant(true)
        )
        
        // Cannot expand (not enough cards)
        WinProbabilityCard(
            probability: nil,
            currentHand: nil,
            canExpand: false,
            cacheKey: "preview3",
            playerCards: [
                PlayingCard(suit: .diamond, rank: .ten),
                PlayingCard(suit: .club, rank: .ten)
            ],
            communityCards: [
                PlayingCard(suit: .heart, rank: .three)
            ],
            isExpanded: .constant(false)
        )
    }
    .padding()
}

