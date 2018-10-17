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
    
    @IBAction open func newGame(_ sender: Any!) {
        
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
}
