//
//  TableLocation.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

struct TableLocation: Hashable, CustomStringConvertible {
    enum LocationType: CustomStringConvertible {
        case none
        case freeCell
        case stack
        case column
        case deck
        
        var description: String {
            switch self {
            case .none:
                return "None"
                
            case .freeCell:
                return "Free Cell"
                
            case .stack:
                return "Stack"
                
            case .column:
                return "Column"
                
            case .deck:
                return "Deck"
            }
        }
    }
    let type: LocationType
    let number: UInt16
    
    var description: String {
        return "\(type):\(number)"
    }
}

extension TableLocation {
    init(none: ()) {
        type = .none
        number = 0
    }
}
