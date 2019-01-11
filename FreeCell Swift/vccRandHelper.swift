//
//  vccRandHelper.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Foundation

/// Visual C and C++ 6 `srand` and `rand`.
///
/// Adapted from implementation found on the internet
/// http://www.codeguru.com/forum/showthread.php?t=312416&goto=nextnewest
struct VCCRandomNumberGenerator: RandomNumberGenerator {
    private(set) var holdrand: UInt64 = 1
    
    mutating func next() -> UInt64 {
        holdrand = holdrand &* 214013 &+ 2531011
        let toRet = (holdrand >> 16) & 0x7fff
		return toRet
    }
    
    mutating func seed(_ seed: UInt64) {
        holdrand = seed
    }
}
