//
//  CardView.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

final class CardView {
	private let cards: [Card: NSImage]
	private let selectedCards: [Card: NSImage]
	private let blank: NSImage
	private let selectedBlank: NSImage
	let cardSize: NSSize
	
	init() {
		let bonded = NSImage(named: "bonded")!
		let bondedSize = bonded.size
		
		cardSize = NSSize(width: bondedSize.width / 13, height: bondedSize.height / 5)
		
		do { // drawBlanks
			// Placeholder blank
			do {
				let card1x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width), pixelsHigh: Int(cardSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				let card2x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width) * 2, pixelsHigh: Int(cardSize.height) * 2, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				card2x.size = cardSize
				
				blank = NSImage(size: cardSize)
				let source = NSRect(origin: CGPoint(x: 0, y: bondedSize.height - 5 * cardSize.height), size: cardSize)
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card1x)
				bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card2x)
				bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.restoreGraphicsState()
				blank.addRepresentations([card1x, card2x])
			}
			
			// Selected blank (for placeholders and compositing selected cards)
			do {
				let card1x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width), pixelsHigh: Int(cardSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				let card2x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width) * 2, pixelsHigh: Int(cardSize.height) * 2, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				card2x.size = cardSize
				selectedBlank = NSImage(size: cardSize)
				let source = NSRect(origin: CGPoint(x: cardSize.width, y: bondedSize.height - 5 * cardSize.height), size: cardSize)
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card1x)
				bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card2x)
				bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.restoreGraphicsState()
				selectedBlank.addRepresentations([card1x, card2x])
			}
		}
		
		do { // drawCards
			var dict = [Card: NSImage]()
			dict.reserveCapacity(52)
			
			for i in Card.Suit.allCases {
				for j in Card.Rank.allCases {
					let card1x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width), pixelsHigh: Int(cardSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
					let card2x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width) * 2, pixelsHigh: Int(cardSize.height) * 2, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
					card2x.size = cardSize
					NSGraphicsContext.saveGraphicsState()
					NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card1x)
					let card = NSImage(size: cardSize)
					let source = NSRect(origin:
						CGPoint(x: CGFloat(j.rawValue - 1) * cardSize.width,
								y: bondedSize.height - CGFloat(i.rawValue + 1) * cardSize.height),
										size: cardSize)
					bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
					NSGraphicsContext.current?.flushGraphics()
					NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card2x)
					bonded.draw(at: .zero, from: source, operation: .copy, fraction: 1)
					NSGraphicsContext.current?.flushGraphics()
					NSGraphicsContext.restoreGraphicsState()
					card.addRepresentations([card1x, card2x])
					
					dict[Card(suit: i, rank: j)] = card
				}
			}
			cards = dict
		}
		
		do { // drawSelectedCards
			var dict = [Card: NSImage]()
			dict.reserveCapacity(52)

			for (card, cardImage) in cards {
				let card1x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width), pixelsHigh: Int(cardSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				let card2x = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cardSize.width) * 2, pixelsHigh: Int(cardSize.height) * 2, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
				card2x.size = cardSize

				let selectedCardImage = NSImage(size: cardSize)
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card1x)
				cardImage.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
				selectedBlank.draw(at: .zero, from: .zero, operation: .sourceAtop, fraction: 0.5)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: card2x)
				cardImage.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
				selectedBlank.draw(at: .zero, from: .zero, operation: .sourceAtop, fraction: 0.5)
				NSGraphicsContext.current?.flushGraphics()
				NSGraphicsContext.restoreGraphicsState()
				selectedCardImage.addRepresentations([card1x, card2x])

				dict[card] = selectedCardImage
			}
			
			selectedCards = dict
		}
	}
	
	func image(for card: Card?, selected isSelected: Bool) -> NSImage! {
		guard let card = card else {
			return isSelected ? selectedBlank : blank
		}
		return (isSelected ? selectedCards : cards)[card]
	}
	
	
	var overlap: Int {
		return Int(cardSize.height / 3)
	}
	
	var smallOverlap: Int {
		return Int(cardSize.height / 4.75)
	}
}
