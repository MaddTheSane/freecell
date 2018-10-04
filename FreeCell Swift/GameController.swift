//
//  GameController.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/4/18.
//

import Cocoa

class GameController: NSObject {
    @IBOutlet weak var view: /*GameView!*/ AnyObject!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playNumberDialog: NSPanel!
    @IBOutlet weak var gameNumberField: NSTextField!
    @IBOutlet weak var timeElapsed: NSTextField!
    @IBOutlet weak var movesMade: NSTextField!
    @IBOutlet weak var history: AnyObject!
}
