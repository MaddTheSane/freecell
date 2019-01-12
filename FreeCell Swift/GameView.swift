//
//  GameView.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/17/18.
//

import Cocoa

class GameView: NSView {
	var game: Game? {
		didSet {
			table = game?.table
			needsDisplay = true
		}
	}
	var controller: GameController? {
		didSet {
			cardView = CardView()
		}
	}
	var cardView: CardView? {
		didSet {
			margin = 8;
			edgeMargin = 2 * margin;
			overlap = cardView!.overlap
			smallOverlap = cardView!.smallOverlap
			cardWidth = Int(cardView!.cardSize.width)
			cardHeight = Int(cardView!.cardSize.height)
			
			var size = NSSize(width: edgeMargin + (cardWidth + margin) * 8 - margin + edgeMargin,
							  height: edgeMargin + (cardHeight + margin) * 2 + smallOverlap * 18 + edgeMargin);

			size.height += 22
			controller?.windowSize = size
			needsDisplay = true
		}
	}
	@objc var backgroundColor: NSColor {
		didSet {
			needsDisplay = true
		}
	}
	
	private weak var table: Table?
	private var cardWidth: Int = 0
	private var cardHeight = 0
	private var margin = 8
	private var edgeMargin = 2 * 8
	private var overlap = 0
	private var smallOverlap = 0

	override init(frame frameRect: NSRect) {
		let defaults = UserDefaults.standard
		
		// Default colour is a nice shade of green
		var color = NSColor(calibratedRed: 0.2, green: 0.4, blue: 0.1, alpha: 1)
		let data = NSKeyedArchiver.archivedData(withRootObject: color)
		
		// Set the default
		defaults.register(defaults: [gameBackgroundColour: data])
		
		// Then try to read the preference
		if let data = defaults.data(forKey: gameBackgroundColour), let otherColor = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
			color = otherColor
		}
		
		// And set the colour
		backgroundColor = color
		super.init(frame: frameRect)
	}
	
	required init?(coder decoder: NSCoder) {
		let defaults = UserDefaults.standard
		
		// Default colour is a nice shade of green
		var color = NSColor(calibratedRed: 0.2, green: 0.4, blue: 0.1, alpha: 1)
		let data = NSKeyedArchiver.archivedData(withRootObject: color)
		
		// Set the default
		defaults.register(defaults: [gameBackgroundColour: data])
		
		// Then try to read the preference
		if let data = defaults.data(forKey: gameBackgroundColour), let otherColor = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
			color = otherColor
		}
		
		// And set the colour
		backgroundColor = color
		super.init(coder: decoder)
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		backgroundColor.set()
		NSBezierPath.fill(frame)
		
		guard let game = game, let cardView = cardView else {
			return
		}
		
		for i in 0 ..< NUMBER_OF_FREE_CELLS {
			let location = TableLocation(type: .freeCell, number: UInt16(i))
			let origin = NSPoint(x: CGFloat(edgeMargin + (cardWidth + margin) * i), y: frame.size.height - CGFloat(edgeMargin + cardHeight))
			let card = table?.firstCard(at: location)
			let selected = game.isSelected(location)
			let image = cardView.image(for: card, selected: selected)
			let operation: NSCompositingOperation
			
			if card == nil && !selected {
				operation = .plusLighter
			} else {
				operation = .sourceOver
			}
			
			image?.draw(at: origin, from: .zero, operation: operation, fraction: card == nil ? 0.5 : 1.0)
		}
		
		for i in 0 ..< NUMBER_OF_STACKS {
			let location = TableLocation(type: .stack, number: UInt16(i))
			let origin = NSPoint(x: CGFloat(edgeMargin + (cardWidth + margin) * (i + 4)), y: frame.size.height - CGFloat(edgeMargin + cardHeight))
			let card = table?.firstCard(at: location)
			let selected = game.isSelected(location)
			let image = cardView.image(for: card, selected: selected)
			let operation: NSCompositingOperation
			
			if card == nil && !selected {
				operation = .plusLighter
			} else {
				operation = .sourceOver
			}
			
			image?.draw(at: origin, from: .zero, operation: operation, fraction: card == nil ? 0.5 : 1.0)
		}
		
		for i in 0 ..< NUMBER_OF_COLUMNS {
			let location = TableLocation(type: .column, number: UInt16(i))
			let column = table!.array(for: location)!
			let count = column.count
			let maxHeight = 19 * smallOverlap
			
			let o = (count * overlap > maxHeight) ? maxHeight/count : overlap;
			
			var curRow: Int = 0
			for (row, card) in column.enumerated() {
				let origin = NSPoint(x: CGFloat(edgeMargin + (cardWidth + margin) * i),
									 y: frame.size.height - CGFloat(edgeMargin)
										- CGFloat((cardHeight + margin) * 2) - CGFloat(o * row));
				let image = cardView.image(for: card, selected: game.isSelected(card))
				image?.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
				curRow = row
			}
			
			// If the column is empty and selected, draw the selected image
			if curRow == 0 && game.isSelected(TableLocation(type: .column, number: UInt16(i))) {
				let origin = NSPoint(x: CGFloat(edgeMargin + (cardWidth + margin) * i),
									 y: frame.size.height - CGFloat(edgeMargin)
										- CGFloat((cardHeight + margin) * 2));
				let image = cardView.image(for: nil, selected: true)!
				image.draw(at: origin, from: .zero, operation: .plusDarker, fraction: 0.5)
			}
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		var location: TableLocation? = nil
		let pos = event.locationInWindow
		let frame = self.frame
		
		if Int(pos.x) > edgeMargin && Int(pos.x) < Int(frame.size.width) - edgeMargin
			&& Int(pos.y) < Int(frame.size.height) - edgeMargin {
			if pos.y >= frame.size.height - CGFloat(cardHeight + margin) {
				if (pos.x < CGFloat(edgeMargin + (cardWidth + margin) * NUMBER_OF_FREE_CELLS)) {
					location = TableLocation(type: .freeCell, number: UInt16((pos.x - CGFloat(edgeMargin))/CGFloat(cardWidth + margin)))
				} else {
					location = TableLocation(type: .stack, number: UInt16((pos.x - CGFloat(edgeMargin))/CGFloat(cardWidth + margin)) - 4)
				}
			} else if (pos.y <= frame.size.height - CGFloat(cardHeight - margin * 2)) {
				location = TableLocation(type: .column, number: UInt16((pos.x - CGFloat(edgeMargin))/CGFloat(cardWidth + margin)))
			}
		}
		
		if let location = location {
			// Take any even number of clicks as a double-click. This allows a
			// quad-click to be understood as two double-clicks in quick succession,
			// which makes perfect UI sense in this case.
			if (event.clickCount % 2) == 0 {
				game?.doubleClicked(location)
			} else {
				game?.clicked(location)
			}
		}
	}
	
	override var isOpaque: Bool {
		return true
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	override func keyDown(with event: NSEvent) {
		if let key = event.characters {
			switch key {
			case "1", "a", "A":
				game?.hilightedRanks.insert(.ace)
				needsDisplay = true
				return
				
			case "2":
				game?.hilightedRanks.insert(.two)
				needsDisplay = true
				return
				
			case "3":
				game?.hilightedRanks.insert(.three)
				needsDisplay = true
				return
				
			case "4":
				game?.hilightedRanks.insert(.four)
				needsDisplay = true
				return
				
			case "5":
				game?.hilightedRanks.insert(.five)
				needsDisplay = true
				return
				
			case "6":
				game?.hilightedRanks.insert(.six)
				needsDisplay = true
				return
				
			case "7":
				game?.hilightedRanks.insert(.seven)
				needsDisplay = true
				return
				
			case "8":
				game?.hilightedRanks.insert(.eight)
				needsDisplay = true
				return
				
			case "9":
				game?.hilightedRanks.insert(.nine)
				needsDisplay = true
				return
				
			case "0":
				game?.hilightedRanks.insert(.ten)
				needsDisplay = true
				return
				
			case "j", "J":
				game?.hilightedRanks.insert(.jack)
				needsDisplay = true
				return
				
			case "q", "Q":
				game?.hilightedRanks.insert(.queen)
				needsDisplay = true
				return
				
			case "k", "K":
				game?.hilightedRanks.insert(.king)
				needsDisplay = true
				return
				
			default:
				break
			}
		}
		super.keyDown(with: event)
	}

	override func keyUp(with event: NSEvent) {
		if let key = event.characters {
			switch key {
			case "1", "a", "A":
				game?.hilightedRanks.remove(.ace)
				needsDisplay = true
				return
				
			case "2":
				game?.hilightedRanks.remove(.two)
				needsDisplay = true
				return
				
			case "3":
				game?.hilightedRanks.remove(.three)
				needsDisplay = true
				return
				
			case "4":
				game?.hilightedRanks.remove(.four)
				needsDisplay = true
				return
				
			case "5":
				game?.hilightedRanks.remove(.five)
				needsDisplay = true
				return
				
			case "6":
				game?.hilightedRanks.remove(.six)
				needsDisplay = true
				return
				
			case "7":
				game?.hilightedRanks.remove(.seven)
				needsDisplay = true
				return
				
			case "8":
				game?.hilightedRanks.remove(.eight)
				needsDisplay = true
				return
				
			case "9":
				game?.hilightedRanks.remove(.nine)
				needsDisplay = true
				return
				
			case "0":
				game?.hilightedRanks.remove(.ten)
				needsDisplay = true
				return
				
			case "j", "J":
				game?.hilightedRanks.remove(.jack)
				needsDisplay = true
				return
				
			case "q", "Q":
				game?.hilightedRanks.remove(.queen)
				needsDisplay = true
				return
				
			case "k", "K":
				game?.hilightedRanks.remove(.king)
				needsDisplay = true
				return
				
			default:
				break
			}
		}
		super.keyUp(with: event)
	}
}
