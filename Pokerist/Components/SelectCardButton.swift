import SwiftUI

struct SelectCardButton: View {
    // MARK: - State
    @State private var isPresentingPicker = false
    @Binding var selectedSuit: Suit?
    @Binding var selectedRank: Rank?
    
    // MARK: - Swipe to Delete State
    @State private var dragOffset: CGFloat = 0
    @State private var isDeleting = false
    
    // MARK: - Game State (optional for smart card disabling)
    var gameState: GameState?
    var editingCard: PlayingCard?
    
    // MARK: - Size Configuration
    var sizeConfig: CardSizeConfig = .medium
    
    // Swipe threshold for deletion
    private let deleteThreshold: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Delete background (revealed when swiping up)
            DeleteBackground(
                isVisible: dragOffset < -10,
                cornerRadius: sizeConfig.cornerRadius,
                revealAmount: min(abs(dragOffset), deleteThreshold)
            )
            
            // Card button
            Button(action: {
                if !isDeleting {
                    isPresentingPicker = true 
                }
            }) {
                ZStack {
                    // Card background: liquid-glass-like with grey tint
                    RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                                .fill(Color.gray.opacity(0.08))
                        )

                    // Content
                    Group {
                        if let suit = selectedSuit, let rank = selectedRank {
                            Text("\(rank.display)\(suit.symbol)")
                                .font(.system(size: sizeConfig.fontSize, weight: .semibold, design: .rounded))
                                .foregroundStyle(suit.color)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .accessibilityLabel("Selected card: \(rank.accessibility) of \(suit.accessibility)")
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: sizeConfig.fontSize, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Select a card")
                        }
                    }
                    .padding(sizeConfig.padding)
                }
                .contentShape(RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous))
                .aspectRatio(2.5/3.5, contentMode: .fit) // Playing card aspect ratio
            }
            .buttonStyle(PressableCardStyle())
            .offset(y: dragOffset)
        }
        .frame(width: sizeConfig.width)
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    // Only allow upward swipes and if card has content
                    // No animation here - follows finger directly
                    if value.translation.height < 0 && hasContent {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if abs(dragOffset) >= deleteThreshold && hasContent {
                        // Delete action
                        deleteCard()
                    } else {
                        // Spring back with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .sheet(isPresented: $isPresentingPicker) {
            CardPickerSheet(
                selectedSuit: $selectedSuit,
                selectedRank: $selectedRank,
                onDone: { isPresentingPicker = false },
                gameState: gameState,
                editingCard: editingCard
            )
            .presentationDetents([.fraction(0.65), .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Properties & Methods
    
    private var hasContent: Bool {
        selectedSuit != nil && selectedRank != nil
    }
    
    private func deleteCard() {
        isDeleting = true
        
        // Animate deletion
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dragOffset = -deleteThreshold * 1.5
        }
        
        // Clear the card after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedSuit = nil
            selectedRank = nil
            
            // Reset state
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dragOffset = 0
            }
            
            isDeleting = false
        }
    }
    
    // MARK: - Size Modifiers
    func xsmall() -> SelectCardButton {
        var button = self
        button.sizeConfig = .xsmall
        return button
    }
    
    func small() -> SelectCardButton {
        var button = self
        button.sizeConfig = .small
        return button
    }
    
    func medium() -> SelectCardButton {
        var button = self
        button.sizeConfig = .medium
        return button
    }
    
    func large() -> SelectCardButton {
        var button = self
        button.sizeConfig = .large
        return button
    }
}

// MARK: - Delete Background
private struct DeleteBackground: View {
    let isVisible: Bool
    let cornerRadius: CGFloat
    let revealAmount: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Red background
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.9), Color.red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: revealAmount)
                
                // Trash icon
                if isVisible {
                    Image(systemName: "trash.fill")
                        .font(.system(size: min(revealAmount * 0.4, 24), weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(min(revealAmount / 40, 1.0))
                }
            }
        }
        .aspectRatio(2.5/3.5, contentMode: .fit)
    }
}

// MARK: - Size Configuration
struct CardSizeConfig {
    let width: CGFloat
    let fontSize: CGFloat
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    static let xsmall = CardSizeConfig(
        width: 35,
        fontSize: 16,
        cornerRadius: 6,
        padding: 4
    )
    
    static let small = CardSizeConfig(
        width: 55,
        fontSize: 24,
        cornerRadius: 10,
        padding: 8
    )
    
    static let medium = CardSizeConfig(
        width: 110,
        fontSize: 40,
        cornerRadius: 14,
        padding: 12
    )
    
    static let large = CardSizeConfig(
        width: 160,
        fontSize: 50,
        cornerRadius: 18,
        padding: 16
    )
}

// MARK: - Styles
private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Swipe up to delete")
            .font(.headline)
        
        SelectCardButton(selectedSuit: .constant(.heart), selectedRank: .constant(.ace))
            .large()
        
        Text("Tap to select a card • Swipe up to delete")
            .foregroundStyle(.secondary)
            .font(.footnote)
            .multilineTextAlignment(.center)
    }
    .padding()
}
