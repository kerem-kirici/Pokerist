import SwiftUI

// MARK: - Playing Card Types


enum Suit: String, CaseIterable, Identifiable {
    case spade, heart, club, diamond

    var id: Self { self }

    var symbol: String {
        switch self {
        case .spade: return "♠︎"
        case .heart: return "♥︎"
        case .club: return "♣︎"
        case .diamond: return "♦︎"
        }
    }

    var color: Color {
        switch self {
        case .heart, .diamond: return .red
        case .spade, .club: return .black
        }
    }

    var accessibility: String {
        switch self {
        case .spade: return "spades"
        case .heart: return "hearts"
        case .club: return "clubs"
        case .diamond: return "diamonds"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .spade: return "suit.spade.fill"
        case .heart: return "suit.heart.fill"
        case .club: return "suit.club.fill"
        case .diamond: return "suit.diamond.fill"
        }
    }
}


enum Rank: String, CaseIterable, Identifiable {
    case two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8", nine = "9", ten = "10"
    case jack = "J", queen = "Q", king = "K", ace = "A"

    var id: Self { self }

    var display: String { rawValue }

    var accessibility: String {
        switch self {
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        case .ace: return "ace"
        default: return rawValue
        }
    }
}

struct PlayingCard: Identifiable, Hashable {
    // Allow empty selection slots by making these optional and mutable
    var suit: Suit?
    var rank: Rank?

    // Unique identifier: for real cards use rank-suit; for empty slots use a stable placeholder
    var id: String {
        if let rank, let suit {
            return "\(rank.rawValue)-\(suit.rawValue)"
        } else {
            return "empty"
        }
    }

    // Convenience properties derived from suit/rank, with safe fallbacks for empty slots
    var display: String {
        if let rank, let suit { return "\(rank.display)\(suit.symbol)" }
        return ""
    }
    var accessibility: String {
        if let rank, let suit { return "\(rank.accessibility) of \(suit.accessibility)" }
        return "no card selected"
    }
    var color: Color { suit?.color ?? .primary }
    var sfSymbolName: String { suit?.sfSymbolName ?? "questionmark.square" }

    // MARK: - Initializers
    init(suit: Suit?, rank: Rank?) {
        self.suit = suit
        self.rank = rank
    }

    nonisolated init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
    }

    // A ready-to-use, ordered 52-card deck (non-empty real cards)
    static var standard52Deck: [PlayingCard] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in
                PlayingCard(suit: suit, rank: rank)
            }
        }
    }

    // A convenient empty selection slot
    static var empty: PlayingCard { PlayingCard(suit: nil, rank: nil) }
}
