//
//  TableMove.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/7/18.
//

import Foundation

struct TableMove {
	var source: TableLocation
	
	var destination: TableLocation
	
	var count: UInt32 = 1

	init(source newSource: TableLocation, destination newDestination: TableLocation = TableLocation(none: ()), count newCount: UInt32 = 1) {
		self.source = newSource
		destination = newDestination
		
		if newSource.type == .none || newDestination.type == .none {
			count = 0
		} else {
			count = newCount
		}
	}
	
	init() {
		source = TableLocation(none: ())
		destination = TableLocation(none: ())
		count = 0
	}
	
	var reversed: TableMove {
		return TableMove(source: destination, destination: source, count: count)
	}
}
