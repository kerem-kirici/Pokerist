//
//  CardPickerSheet.swift
//  Pokerist
//
//  Created by Kerem Kirici on 4.10.2025.
//

import SwiftUI

// MARK: - Picker Sheet
struct CardPickerSheet: View {
    @Binding var selectedSuit: Suit?
    @Binding var selectedRank: Rank?
    var onDone: () -> Void
    
    // Optional: Pass game state and the card being edited for smart disabling
    var gameState: GameState?
    var editingCard: PlayingCard?

    private let rankColumns: [GridItem] = Array(repeating: GridItem(.flexible(minimum: 44, maximum: 80), spacing: 8), count: 4)
    private let suitColumns: [GridItem] = Array(repeating: GridItem(.flexible(minimum: 44, maximum: 80), spacing: 8), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Suit selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Suit")
                            .font(.headline)
                        LazyVGrid(columns: suitColumns, spacing: 8) {
                            ForEach(Suit.allCases) { suit in
                                let isDisabled = gameState?.isSuitDisabled(suit, withCurrentRank: selectedRank, excludingCard: editingCard) ?? false
                                
                                Toggle(isOn: Binding(
                                    get: { selectedSuit == suit },
                                    set: { isOn in selectedSuit = isOn ? suit : nil }
                                )) {
                                    HStack {
                                        Image(systemName: suit.sfSymbolName)
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(suit.color)
                                        Text(suit.accessibility.capitalized)
                                            .font(.body)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .toggleStyle(SelectionCapsuleStyle(isSelected: selectedSuit == suit))
                                .disabled(isDisabled)
                                .opacity(isDisabled ? 0.4 : 1.0)
                            }
                        }
                    }

                    // Rank selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Value")
                            .font(.headline)
                        LazyVGrid(columns: rankColumns, spacing: 8) {
                            ForEach(Rank.allCases) { rank in
                                let isDisabled = gameState?.isRankDisabled(rank, withCurrentSuit: selectedSuit, excludingCard: editingCard) ?? false
                                
                                Toggle(isOn: Binding(
                                    get: { selectedRank == rank },
                                    set: { isOn in selectedRank = isOn ? rank : nil }
                                )) {
                                    Text(rank.display)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                }
                                .toggleStyle(SelectionCapsuleStyle(isSelected: selectedRank == rank))
                                .disabled(isDisabled)
                                .opacity(isDisabled ? 0.4 : 1.0)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle("Select Card")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDone()
                    }
                    .disabled(!(selectedSuit != nil && selectedRank != nil))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        selectedSuit = nil
                        selectedRank = nil
                    }
                }
            }
        }
    }
}


private struct SelectionCapsuleStyle: ToggleStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            configuration.label
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}
