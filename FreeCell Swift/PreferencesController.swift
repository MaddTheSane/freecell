//
//  PreferencesController.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/26/18.
//

import Cocoa

class PreferencesController: NSObject {
	@IBOutlet weak var gameView: GameView!
	@IBOutlet weak var autoStack: NSButton!
	@IBOutlet weak var superMove: NSButton!
	@IBOutlet weak var backgroundColour: NSColorWell!
	@IBOutlet weak var window: NSWindow!

	override func awakeFromNib() {
		let defaults = UserDefaults.standard
		defaults.register(defaults: ["gameSuperMove": true, "gameAutoStack": true])
		
		autoStack.state = defaults.bool(forKey: "gameAutoStack") ? .on : .off
		superMove.state = defaults.bool(forKey: "gameSuperMove") ? .on : .off
		
		if let data = defaults.data(forKey: "backgroundColour"), let colour = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
			backgroundColour.color = colour
		}
	}
	
	@IBAction func openWindow(_ sender: Any?) {
		window.makeKeyAndOrderFront(self)
	}
	
	@IBAction func autoStackClicked(_ sender: Any?) {
		let state = autoStack.state == .on
		UserDefaults.standard.set(state, forKey: "gameAutoStack")
	}
	
	@IBAction func superMoveClicked(_ sender: Any?) {
		let state = superMove.state == .on
		UserDefaults.standard.set(state, forKey: "gameSuperMove")
	}
	
	@IBAction func backgroundColourChosen(_ sender: Any?) {
		let colour = backgroundColour.color
		UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: colour), forKey: "backgroundColour")
		gameView.backgroundColor = colour
	}
}
