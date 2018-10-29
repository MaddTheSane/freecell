//
//  GameController.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

@NSApplicationMain
class GameController: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuItemValidation {
    @IBOutlet weak var view: GameView!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playNumberDialog: NSPanel!
    @IBOutlet weak var gameNumberField: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var movesMade: NSTextField!
    @IBOutlet weak var history: HistoryController!
	private var game: Game? {
		willSet {
			if game?.inProgress ?? false {
				game?.gameOver(with: .loss)
			}
			
			if game?.result == .win || game?.result == .loss {
				recordGame()
			}
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
			updateTime(timer)
			moveMade()
		}
	}
	
	@objc private func updateTime(_ aTimer: Timer?) {
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
        startGame()
    }
    
    @IBAction open func playGameNumber(_ sender: Any!) {
		//NSApp.stopModal()
		window.endSheet(playNumberDialog, returnCode: .OK)
		//startGame()
    }
    
    @IBAction open func openPlayNumberDialog(_ sender: Any!) {
		if window.attachedSheet == nil {
			window.beginSheet(playNumberDialog) { (retVal) in
				if retVal == .OK {
					self.startGame()
				}
			}
		}
    }
    
    @IBAction open func closePlayNumberDialog(_ sender: Any!) {
		//NSApp.stopModal()
		window.endSheet(playNumberDialog, returnCode: .cancel)
    }
    
    @IBAction open func showHint(_ sender: Any!) {
		game?.setHint()
		if game?.hint != nil {
			view.needsDisplay = true
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) { [weak self] in
				self?.game?.hint = nil
				self?.view.needsDisplay = true
			}
		}
    }
    
    @IBAction open func undo(_ sender: Any!) {
        game?.undo()
    }
    
    @IBAction open func redo(_ sender: Any!) {
        game?.redo()
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		history.awakeFromNib()

		updateTime(timer)
		moveMade()
		
		window.isReleasedWhenClosed = false
		window.miniwindowTitle = "Freecell"
		
		view.controller = self
		newGame(self)
		timer = nil;
	}
	
	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if !flag {
			newGame(self)
		}
		
		return true
	}
	
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		guard let game = game, game.inProgress else {
			return .terminateNow
		}
		
		let alert = NSAlert()
		alert.messageText = NSLocalizedString("closeTitle", comment: "windowShouldClose sheet title")
		alert.informativeText = NSLocalizedString("closeText", comment: "windowShouldClose sheet text")
		alert.addButton(withTitle: NSLocalizedString("closeButton", comment: "Close button"))
		alert.addButton(withTitle: NSLocalizedString("cancelButton", comment: "Cancel button"))
		alert.beginSheetModal(for: window) { (returnCode) in
			if returnCode == .alertFirstButtonReturn {
				self.window.close()
			}
			NSApp.reply(toApplicationShouldTerminate: returnCode == .alertFirstButtonReturn)
		}
		
		return .terminateLater
	}
	
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if menuItem.tag == 1 {
			return game?.canUndo ?? false
		} else if menuItem.tag == 2 {
			return game?.canRedo ?? false
		}
		
		return true
	}
	
	func windowWillClose(_ notification: Notification) {
		if (notification.object as AnyObject?) === window {
			game = nil
		}
	}
	
	func moveMade() {
		let currentMoves = game?.moves ?? 0
		let shortestMoves = history.shortestMoves
		movesMade.stringValue = "\(currentMoves) \(NSLocalizedString("moves", comment: "moves")) (\(NSLocalizedString("bestIs", comment: "best is")) \(shortestMoves))"
	}
	
	func gameOver() {
		var title: String; var defaultButton: String; var alternateButton: String; var message: String;
		var selector: (NSApplication.ModalResponse) -> Void
		guard let result = game?.result, let moves = game?.moves else {
			return
		}
		
		timer?.fire()
		
		timer?.invalidate()
		timer = nil
		
		switch result {
		case .win:
			title = NSLocalizedString("wonTitle", comment: "Won sheet title");
			defaultButton = NSLocalizedString("wonDefaultButton", comment: "Won sheet default button");
			alternateButton = NSLocalizedString("showHistoryButton", comment: "Show history button");
			message = NSLocalizedString("wonText", comment: "Won sheet text");
			selector = { (returnCode) in
				switch returnCode {
				case .alertSecondButtonReturn:
					self.history.openWindow(self)
					
				case .alertThirdButtonReturn:
					self.newGame(self)
					
				default:
					break
				}
			}

		case .loss:
			title = NSLocalizedString("lostTitle", comment: "Lost sheet title");
			defaultButton = NSLocalizedString("lostDefaultButton", comment: "Lost sheet default button");
			alternateButton = NSLocalizedString("retryGameButton", comment: "Retry game button");
			message = NSLocalizedString("lostText", comment: "Lost sheet text");
			selector = { (returnCode) in
				switch returnCode {
				case .alertSecondButtonReturn:
					self.retryGame(self)
					
				case .alertThirdButtonReturn:
					self.newGame(self)
					
				default:
					break
				}
			}

		default:
			return
		}
		recordGame()
		
		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = String(format: message, moves)
		alert.addButton(withTitle: defaultButton)
		alert.addButton(withTitle: alternateButton)
		alert.addButton(withTitle: NSLocalizedString("newGameButton", comment: "New game button"))
		alert.beginSheetModal(for: window, completionHandler: selector)
	}
	
	func recordGame() {
		guard let game = game else {
			NSSound.beep()
			return
		}
		history.addRecord(gameNumber: game.gameNumber, result: game.result, moves: game.moves, duration: game.duration, date: game.startDate)
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
