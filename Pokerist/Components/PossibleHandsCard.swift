//
//  PossibleHandsCard.swift
//  Pokerist
//
//  Created by Kerem Kirici on 5.10.2025.
//

import SwiftUI

// MARK: - Possible Hands Card
struct PossibleHandsCard: View {
    let canExpand: Bool  // Whether there are enough cards to show
    let cacheKey: String
    let playerCards: [PlayingCard]
    let communityCards: [PlayingCard]
    
    @Binding var isExpanded: Bool
    @State private var possibleHandsState: PossibleHandsState = .notLoaded
    @State private var calculationTask: Task<Void, Never>?
    @State private var expandedPossibleHandIds: Set<UUID> = []
    private let analyzer = PokerHandAnalyzer.self
    
    // Cache for possible hands results
    @State private static var possibleHandsCache: [String: [CombinedPossibleHands]] = [:]
    
    enum PossibleHandsState {
        case notLoaded
        case loading
        case loaded([CombinedPossibleHands])
        case error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main header display
            Button(action: {
                if canExpand {
                    let willExpand = !isExpanded
                    
                    if willExpand {
                        // Set loading state immediately (synchronously) before animation
                        possibleHandsState = .loading
                    }
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                    
                    // Load possible hands when expanding
                    if willExpand {
                        loadPossibleHandsIfNeeded()
                    } else {
                        // Cancel calculation if collapsing
                        calculationTask?.cancel()
                    }
                }
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Possible Hands")
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }.buttonStyle(.plain)
            .contentShape(Rectangle())
            
            // Expanded content (only if expansion is allowed and expanded)
            if canExpand && isExpanded {
                Divider()
                
                switch possibleHandsState {
                case .notLoaded:
                    // Should not happen, but show loading
                    LoadingView()
                    
                case .loading:
                    LoadingView()
                    
                case .loaded(let possibleHands):
                    if possibleHands.isEmpty {
                        EmptyPossibleHandsView(
                            playerCards: playerCards,
                            communityCards: communityCards
                        )
                    } else {
                        PossibleHandsListView(
                            possibleHands: possibleHands,
                            expandedPossibleHandIds: $expandedPossibleHandIds
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
                                Color.purple.opacity(0.1),
                                Color.purple.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
                
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
    }
    
    // MARK: - Helper Functions
    
    private func loadPossibleHandsIfNeeded() {
        // Cancel any existing task
        calculationTask?.cancel()
        
        // Check cache first
        if let cached = Self.possibleHandsCache[cacheKey] {
            // Wait for expansion animation (0.4s) + buffer for loading animation
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                guard !Task.isCancelled else { return }
                possibleHandsState = .loaded(cached)
            }
            return
        }
        
        // Wait for expansion animation to complete + loading animation to be visible
        calculationTask = Task { @MainActor in
            do {
                // Wait for expansion animation (0.4s spring) + loading animation buffer
                try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                
                // Check if task was cancelled during delay
                guard !Task.isCancelled else { return }
                
                // Run calculation in background
                let hands = await PokerHandAnalyzer.analyzePossibleHandsAsync(
                    playerCards: playerCards,
                    communityCards: communityCards
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                // Cache the results
                Self.possibleHandsCache[cacheKey] = hands
                
                // Update state (already on MainActor)
                possibleHandsState = .loaded(hands)
            } catch {
                possibleHandsState = .error
            }
        }
    }
    
    func resetForNewCards() {
        // Close expansion and reset state
        isExpanded = false
        possibleHandsState = .notLoaded
        calculationTask?.cancel()
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
                Text("Calculating possible hands...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - Empty View
private struct EmptyPossibleHandsView: View {
    let playerCards: [PlayingCard]
    let communityCards: [PlayingCard]
    
    private var allCardsRevealed: Bool {
        let validCommunityCards = communityCards.filter { $0.suit != nil && $0.rank != nil }
        return validCommunityCards.count >= 5
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if allCardsRevealed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
                Text("All cards revealed - no more draws")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.yellow)
                Text("No significant better draws available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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
            Text("Failed to calculate possible hands")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Possible Hands List View
private struct PossibleHandsListView: View {
    let possibleHands: [CombinedPossibleHands]
    @Binding var expandedPossibleHandIds: Set<UUID>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(possibleHands.prefix(8)), id: \.id) { possibleHand in
                ExpandablePossibleHandRow(
                    possibleHand: possibleHand,
                    isExpanded: expandedPossibleHandIds.contains(possibleHand.id),
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if expandedPossibleHandIds.contains(possibleHand.id) {
                                expandedPossibleHandIds.remove(possibleHand.id)
                            } else {
                                expandedPossibleHandIds.insert(possibleHand.id)
                            }
                        }
                    }
                )

                if possibleHand.id != Array(possibleHands.prefix(8)).last?.id {
                    Divider()
                }
            }

            if possibleHands.count > 8 {
                Text("+ \(possibleHands.count - 8) more possible hands")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Expandable Possible Hand Row
private struct ExpandablePossibleHandRow: View {
    let possibleHand: CombinedPossibleHands
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 8) {
                // Header row: hand name + combined probability + chevron
                HStack {
                    Image(systemName: possibleHand.handType.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.purple.opacity(0.8))
                        .frame(width: 20)
                    
                    Text(possibleHand.handType.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Spacer()

                    ProbabilityText(probability: possibleHand.totalProbability)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Color.purple.opacity(0.15))
                        )

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                // Expanded content: show required cards instead of scenarios
                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        Divider()

                        // Show the required cards for this possible hand
                        ForEach(0..<possibleHand.requiredCombinations.count, id: \.self) { index in
                            HStack(spacing: 8) {
                                Text("Need:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                RequiredCardsView(requiredCards: possibleHand.requiredCombinations[index])
                                
                                Spacer()
                                
                                ProbabilityText(probability: possibleHand.probabilities[index], decimalPointIndex: 1)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule().fill(Color.purple.opacity(0.15))
                                    )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}
