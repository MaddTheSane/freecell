//
//  Card.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

struct Card: Hashable, CustomStringConvertible {
    /// Suit order is important: must match the card graphics file.
    enum Suit: Int32, CustomStringConvertible {
        case clubs = 0
        case diamonds
        case hearts
        case spades
        
        var description: String {
            switch self {
                //@"Clubs", @"Diamonds", @"Hearts", @"Spades"
                
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
    
    enum Rank: Int32 {
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
    }

    var suit: Suit
    var rank: Rank
    
    var description: String {
        return "\(rank) of \(suit)"
    }
}

extension Card {
    var isRed: Bool {
        return suit.isRed
    }
    
    var isBlack: Bool {
        return suit.isBlack
    }
}
