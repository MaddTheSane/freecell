//
//  CardView.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

class CardView: NSObject {
	private let cards: [Card: NSImage]
	private let selectedCards: [Card: NSImage]
	private let blank: NSImage
	private let selectedBlank: NSImage
	let cardSize: NSSize
	
	override init() {
		let bonded = NSImage(named: "bonded")!
		let bondedSize = bonded.size
		
		cardSize = NSSize(width: bondedSize.width / 13, height: bondedSize.height / 5)
		
		do { // drawBlanks
			// Placeholder blank
			blank = NSImage(size: cardSize)
			var source = NSRect(origin: CGPoint(x: 0, y: bondedSize.height - 5 * cardSize.height), size: cardSize)
			blank.lockFocus()
			bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
			blank.unlockFocus()
			
			// Selected blank (for placeholders and compositing selected cards)
			selectedBlank = NSImage(size: cardSize)
			source = NSRect(origin: CGPoint(x: cardSize.width, y: bondedSize.height - 5 * cardSize.height), size: cardSize)
			selectedBlank.lockFocus()
			bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
			selectedBlank.unlockFocus()
		}
		
		do { // drawCards
			var dict = [Card: NSImage]()
			dict.reserveCapacity(52)
			
			for i in Card.Suit.allCases {
				for j in Card.Rank.allCases {
					let card = NSImage(size: cardSize)
					let source = NSRect(origin:
						CGPoint(x: CGFloat(j.rawValue - 1) * cardSize.width,
								y: bondedSize.height - CGFloat(i.rawValue + 1) * cardSize.height),
										size: cardSize)
					card.lockFocus()
					bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
					card.unlockFocus()
					
					dict[Card(suit: i, rank: j)] = card
				}
			}
			cards = dict
		}
		
		do { // drawSelectedCards
			var dict = [Card: NSImage]()
			dict.reserveCapacity(52)

			for (card, cardImage) in cards {
				let selectedCardImage = NSImage(size: cardSize)
				selectedCardImage.lockFocus()
				cardImage.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
				selectedBlank.draw(at: .zero, from: .zero, operation: .sourceAtop, fraction: 0.5)
				selectedCardImage.unlockFocus()
				dict[card] = selectedCardImage
			}
			
			selectedCards = dict
		}

		super.init()
	}
	
	func image(for card: Card?, selected isSelected: Bool) -> NSImage! {
		guard let card = card else {
			return isSelected ? selectedBlank : blank
		}
		return (isSelected ? selectedCards : cards)[card]
	}
	
	
	var overlap: UInt32 {
		return UInt32(cardSize.height / 3)
	}
	
	var smallOverlap: UInt32 {
		return UInt32(cardSize.height / 4.75)
	}
}
