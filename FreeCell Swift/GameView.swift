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
	var backgroundColor: NSColor {
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
		defaults.register(defaults: ["backgroundColour": data])
		
		// Then try to read the preference
		if let data = defaults.data(forKey: "backgroundColour"), let otherColor = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
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
		defaults.register(defaults: ["backgroundColour": data])
		
		// Then try to read the preference
		if let data = defaults.data(forKey: "backgroundColour"), let otherColor = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
			color = otherColor
		}
		
		// And set the colour
		backgroundColor = color
		super.init(coder: decoder)
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
