//
//  Table.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

let NUMBER_OF_COLUMNS = 8
let NUMBER_OF_STACKS = 4
let NUMBER_OF_FREE_CELLS = 4
let NUMBER_OF_DECKS = 1

final class Table {
	private var columns: [[Card]]
	private var stacks: [[Card]]
	private var freeCells: [[Card]]
	private var decks: [[Card]]
	
	init() {
		freeCells = [[Card]](repeating: [Card](), count: NUMBER_OF_FREE_CELLS)
		stacks = [[Card]](repeating: [Card](), count: NUMBER_OF_STACKS)
		columns = [[Card]](repeating: [Card](), count: NUMBER_OF_COLUMNS)
		decks = [[Card]](repeating: [Card](), count: NUMBER_OF_DECKS)
		
		for i in Card.Rank.allCases {
			// Use Windows suit ordering
			for j in Card.Suit.allCases {
				decks[0].append(Card(suit: j, rank: i))
			}
		}
	}
	
	func array(for locationType: TableLocation.LocationType) -> [[Card]]? {
		switch locationType {
		case .none:
			return nil
			
		case .freeCell:
			return freeCells
			
		case .stack:
			return stacks
			
		case .column:
			return columns
			
		case .deck:
			return decks
		}
	}

	func shuffleDeck<T>(using randomGen: inout T)  where T : RandomNumberGenerator {
		var theDeck = decks[0]
		theDeck.shuffle(using: &randomGen)
		decks[0] = theDeck
	}
	
	func move(_ move: TableMove) {
		// FIXME: rewrite to have better speed?
		guard var source = array(for: move.source),
			var destination = array(for: move.destination) else {
				return
		}
		
		let first = source.count - Int(move.count)
		let last = source.count
		
		for _ in first ..< last {
			destination.append(source[first])
			source.remove(at: first)
		}
		
		// Convoluted mess incoming!
		switch (move.source.type, move.source.number) {
		case (.deck, 0):
			decks[0] = source

		case (.freeCell, let num):
			freeCells[Int(num)] = source

		case (.stack, let num):
			stacks[Int(num)] = source

		case (.column, let num):
			columns[Int(num)] = source

		default:
			fatalError("Somehow got here!")
		}

		switch (move.destination.type, move.destination.number) {
		case (.deck, 0):
			fatalError("Putting cards back onto the deck!?")
			
		case (.freeCell, let num):
			freeCells[Int(num)] = destination
			
		case (.stack, let num):
			stacks[Int(num)] = destination
			
		case (.column, let num):
			columns[Int(num)] = destination
			
		default:
			fatalError("Somehow got here!")
		}
	}
	
	func array(for location: TableLocation) -> [Card]? {
		guard let locationType = array(for: location.type) else {
			return nil
		}
		return locationType[Int(location.number)]
	}
	
	func numberOfEmptyTableLocation(_ type: TableLocation.LocationType) -> Int {
		var n = 0
		
		guard let enumu = array(for: type) else {
			return 0
		}
		
		for location in enumu {
			if location.count == 0 {
				n += 1
			}
		}
		
		return n
	}
	
	func cardNumber(_ n: Int, at location: TableLocation) -> Card? {
		guard let array = self.array(for: location),
			n <= array.count, n != 0 else {
				return nil
		}
		
		return array[array.count - n]
	}
	
	func firstCard(at location: TableLocation) -> Card? {
		return cardNumber(1, at: location)
	}
}
