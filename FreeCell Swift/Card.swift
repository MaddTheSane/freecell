//
//  Card.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

/// Suit order is important: must match the card graphics file.
public enum Suit : Int32 {
    case clubs = 0
    case diamonds
    case hearts
    case spades
}

public enum Rank : Int32 {
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
}
