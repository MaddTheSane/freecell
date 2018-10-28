//
//  GameController.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

@NSApplicationMain
class GameController: NSObject, NSApplicationDelegate {
    @IBOutlet weak var view: GameView!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playNumberDialog: NSPanel!
    @IBOutlet weak var gameNumberField: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var movesMade: NSTextField!
    @IBOutlet weak var history: HistoryController!
	private var game: Game? {
		didSet {
			
		}
	}
	private weak var cardView: CardView?
	private var timer: Timer?
	
	private var timeIntervalFormatter: DateComponentsFormatter = {
		let format = DateComponentsFormatter()
		format.zeroFormattingBehavior = [.pad]
		format.allowedUnits = [.hour, .minute, .second]
		return format
	}()

	func playGame(withNumber newgame: UInt64) {
		gameNumberField.objectValue = NSNumber(value: newgame)
		startGame()
	}
	
	private func startGame() {
		if let attachedSheet = window.attachedSheet {
			// Clear up the you-won/you-lost dialog if it's open
			if game?.inProgress ?? false {
				window.endSheet(attachedSheet)
				NSApp.stopModal()
				// Otherwise, we must already be checking whether or not to end the game
			} else {
				return
			}
		}
		if game?.inProgress ?? false {
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("newGameTitle", comment: "New game sheet title")
			alert.informativeText = NSLocalizedString("newGameText", comment: "New game sheet text")
			alert.addButton(withTitle: NSLocalizedString("newGameButton", comment: "New game button"))
			alert.addButton(withTitle: NSLocalizedString("cancelButton", comment: "Cancel button")).keyEquivalent = "\u{1b}"
			alert.beginSheetModal(for: window) { (response) in
				if response == .alertFirstButtonReturn {
					self.game = nil
					self.startGame()
				}
			}
			return
		} else {
			let gameNumber = (gameNumberField.objectValue as? NSNumber)?.uint64Value ?? UInt64(arc4random())
			
			game = Game(view: view, controller: self, gameNumber: gameNumber)
			view.game = game
			
			window.title = String(format: NSLocalizedString("gameWindowTitleFormat", comment: "Format for the title of the game window"), gameNumberField.stringValue)
			window.makeKeyAndOrderFront(self)
			window.makeMain()
			
			timer?.invalidate()
			timer = Timer(timeInterval: 1, target: self, selector: #selector(GameController.updateTime(_:)), userInfo: nil, repeats: true)
			updateTime(timer!)
			moveMade()
		}
	}
	
	@objc private func updateTime(_ aTimer: Timer) {
		var current = TimeInterval()
		var shortest = TimeInterval()
		
		if game?.inProgress ?? false {
			current = Date().timeIntervalSince(game!.startDate)
		} else if game?.result == .unplayed {
			current = game!.duration
		}
		
		if let history = history {
			shortest = history.shortestDuration
		}
		
		if game != nil {
			let format = timeIntervalFormatter
			timeElapsed.stringValue = "(\(format.string(from: current)!) \(NSLocalizedString("bestIs", comment: "best is")) \(format.string(from: shortest)!))"
		}
	}
	
    @IBAction open func newGame(_ sender: Any!) {
		var randNum = UInt64()
		arc4random_buf(&randNum, MemoryLayout<UInt64>.size)
		playGame(withNumber: randNum)
    }
    
    @IBAction open func retryGame(_ sender: Any!) {
        
    }
    
    @IBAction open func playGameNumber(_ sender: Any!) {
        
    }
    
    @IBAction open func openPlayNumberDialog(_ sender: Any!) {
        
    }
    
    @IBAction open func closePlayNumberDialog(_ sender: Any!) {
        
    }
    
    @IBAction open func showHint(_ sender: Any!) {
        
    }
    
    @IBAction open func undo(_ sender: Any!) {
        
    }
    
    @IBAction open func redo(_ sender: Any!) {
        
    }
	
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		return .terminateNow
	}
	
	func moveMade() {
		
	}
	
	func gameOver() {
		
	}
	
	var windowSize: NSSize {
		get {
			return window.frame.size
		}
		set {
			var frame = window.frame
			frame.size = newValue
			window.setFrame(frame, display: true)
		}
	}
}
