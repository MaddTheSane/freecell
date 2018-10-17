//
//  Result.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

enum Result: Int8, CustomStringConvertible, Codable {	
    case unplayed
    case loss
    case win
    
    var description: String {
        switch self {
        case .unplayed:
            return "Unplayed"
            
        case .loss:
            return "Loss"
            
        case .win:
            return "Win"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .win:
            return NSLocalizedString("resultWin", comment: "Result: win")
            
        case .loss:
            return NSLocalizedString("resultLoss", comment: "Result: loss")
            
        default:
            return "Invalid"
        }
    }
}
