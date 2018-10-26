//
//  Card.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

struct Card: Hashable, CustomStringConvertible {
    /// Suit order is important: must match the card graphics file.
    enum Suit: Int32, CustomStringConvertible, CaseIterable {
        case clubs = 0
        case diamonds
        case hearts
        case spades
        
        var description: String {
            switch self {
            case .clubs:
                return "Clubs"
            case .diamonds:
                return "Diamonds"
            case .hearts:
                return "Hearts"
            case .spades:
                return "Spades"
            }
        }
        
        var isRed: Bool {
            return self == .hearts || self == .diamonds
        }
        
        var isBlack: Bool {
            return self == .clubs || self == .spades
        }
    }
    
	enum Rank: Int32, CustomStringConvertible, CaseIterable, Comparable {
        case ace = 1
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case ten
        case jack
        case queen
        case king
        
        var description: String {
            switch self {
            case .ace:
                return "Ace"
                
            case .two:
                return "Two"
                
            case .three:
                return "Three"
                
            case .four:
                return "Four"
                
            case .five:
                return "Five"
                
            case .six:
                return "Six"
                
            case .seven:
                return "Seven"
                
            case .eight:
                return "Eight"
                
            case .nine:
                return "Nine"
                
            case .ten:
                return "Ten"
                
            case .jack:
                return "Jack"
                
            case .queen:
                return "Queen"
                
            case .king:
                return "King"
            }
        }
		
		static func < (lhs: Card.Rank, rhs: Card.Rank) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}
    }

    let suit: Suit
    let rank: Rank
    
    var description: String {
        return "\(rank) of \(suit)"
    }
    
    var isRed: Bool {
        return suit.isRed
    }
    
    var isBlack: Bool {
        return suit.isBlack
    }
}

extension Card {
	func isSuccessor(to other: Card?) -> Bool {
		// An ace is the only successor to a blank space
		guard let other = other else {
			return rank == .ace
		}
		
		// If our suits match, and my rank is one more than the other card, I am
		// its successor.
		return suit == other.suit && rank == Card.Rank(rawValue: other.rank.rawValue + 1)
	}
	
	func isPlayable(on other: Card?) -> Bool {
		// Can play any card on a blank space
		guard let other = other else {
			return true
		}

		// Can't play a king on anything
		if rank == .king {
			return false
		}
		
		// If I am red and the other card is black, or vice versa, and my rank is
		// one less than the other card, I am playable on it.
		return (((self.isRed && other.isBlack) || (self.isBlack && other.isRed))
			&& Card.Rank(rawValue: rank.rawValue + 1) == other.rank)
	}
}
