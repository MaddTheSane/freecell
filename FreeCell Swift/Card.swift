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
    
    
    case ACE = 1
    
    case TWO
    
    case THREE
    
    case FOUR
    
    case FIVE
    
    case SIX
    
    case SEVEN
    
    case EIGHT
    
    case NINE
    
    case TEN
    
    case JACK
    
    case QUEEN
    
    case KING
}
