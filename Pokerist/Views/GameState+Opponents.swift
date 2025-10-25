import Foundation
import SwiftUI
import Combine
import ObjectiveC

extension GameState {
    public typealias OpponentHand = (PlayingCard?, PlayingCard?)

    private struct AssociatedKeys {
        static var opponentHands = "opponentHands"
    }

    public var opponentHands: [OpponentHand] {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.opponentHands) as? [OpponentHand] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.opponentHands, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objectWillChange.send()
        }
    }

    public func setOpponentCard(at handIndex: Int, cardIndex: Int, suit: Suit?, rank: Rank?) {
        guard cardIndex == 0 || cardIndex == 1 else { return }

        var hands = opponentHands
        while hands.count <= handIndex {
            hands.append((nil, nil))
        }

        let card: PlayingCard? = {
            if let s = suit, let r = rank {
                return PlayingCard(suit: s, rank: r)
            } else {
                return nil
            }
        }()

        var hand = hands[handIndex]
        if cardIndex == 0 {
            hand.0 = card
        } else {
            hand.1 = card
        }
        hands[handIndex] = hand

        opponentHands = hands
    }
}
