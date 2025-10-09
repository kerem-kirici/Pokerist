import SwiftUI

/// A non-interactive card display component for showing cards, suits, or ranks
struct CardView: View {
    // MARK: - Display Options
    enum DisplayMode {
        case card(suit: Suit, rank: Rank)
        case suitOnly(Suit)
        case rankOnly(Rank)
        case empty
    }
    
    let mode: DisplayMode
    
    // MARK: - Size Configuration
    var sizeConfig: CardSizeConfig = .medium
    
    var body: some View {
        ZStack {
            // Card background: liquid-glass-like with grey tint
            RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
                .background(
                    RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous)
                        .fill(Color.gray.opacity(0.08))
                )
            
            // Content
            Group {
                switch mode {
                case .card(let suit, let rank):
                    Text("\(rank.display)\(suit.symbol)")
                        .font(.system(size: sizeConfig.fontSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(suit.color)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                case .suitOnly(let suit):
                    Image(systemName: suit.sfSymbolName)
                        .font(.system(size: sizeConfig.fontSize * 0.8, weight: .semibold))
                        .foregroundStyle(suit.color)
                    
                case .rankOnly(let rank):
                    Text(rank.display)
                        .font(.system(size: sizeConfig.fontSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                case .empty:
                    Image(systemName: "questionmark")
                        .font(.system(size: sizeConfig.fontSize * 0.6, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(sizeConfig.padding)
        }
        .contentShape(RoundedRectangle(cornerRadius: sizeConfig.cornerRadius, style: .continuous))
        .aspectRatio(2.5/3.5, contentMode: .fit) // Playing card aspect ratio
        .frame(width: sizeConfig.width)
    }
    
    private var strokeColor: Color {
        switch mode {
        case .card(let suit, _), .suitOnly(let suit):
            return suit.color.opacity(0.3)
        case .rankOnly:
            return Color.black.opacity(0.3)
        case .empty:
            return Color.secondary.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        switch sizeConfig.width {
        case ..<60: return 1.5
        case 60..<120: return 2
        default: return 2
        }
    }
    
    // MARK: - Size Modifiers
    func xsmall() -> CardView {
        var view = self
        view.sizeConfig = .xsmall
        return view
    }
    
    func small() -> CardView {
        var view = self
        view.sizeConfig = .small
        return view
    }
    
    func medium() -> CardView {
        var view = self
        view.sizeConfig = .medium
        return view
    }
    
    func large() -> CardView {
        var view = self
        view.sizeConfig = .large
        return view
    }
}

// MARK: - Convenience Initializers
extension CardView {
    init(suit: Suit, rank: Rank) {
        self.mode = .card(suit: suit, rank: rank)
    }
    
    init(suit: Suit) {
        self.mode = .suitOnly(suit)
    }
    
    init(rank: Rank) {
        self.mode = .rankOnly(rank)
    }
    
    init(card: PlayingCard) {
        if let suit = card.suit, let rank = card.rank {
            self.mode = .card(suit: suit, rank: rank)
        } else {
            self.mode = .empty
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            CardView(suit: .heart, rank: .ace).xsmall()
            CardView(suit: .spade, rank: .king).xsmall()
            CardView(suit: .diamond).xsmall()
            CardView(rank: .seven).xsmall()
        }
        
        HStack(spacing: 12) {
            CardView(suit: .heart, rank: .ace).small()
            CardView(suit: .spade, rank: .king).small()
        }
        
        HStack(spacing: 12) {
            CardView(suit: .heart, rank: .ace).medium()
            CardView(suit: .club, rank: .queen).medium()
        }
        
        CardView(suit: .diamond, rank: .ten).large()
    }
    .padding()
}

