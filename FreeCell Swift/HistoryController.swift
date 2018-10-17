//
//  HistoryController.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/17/18.
//

import Cocoa

private var historySortDescending: String {
	return "historySortDescending"
}

private var historySortColumn: String {
	return "historySortColumn"
}


class HistoryController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var gamesLost: NSTextField!
	@IBOutlet var gamesPlayed: NSTextField!
	@IBOutlet var gamesWon: NSTextField!
	@IBOutlet var retryGame: NSButton!
	@IBOutlet var tableView: NSTableView!
	@IBOutlet var window: NSWindow!
	@IBOutlet var lastPlayedColumn: NSTableColumn!
	//IBOutlet GameController *gameController;
	private let history: History
	private var sortColumn = "date"
	private var sortDescending = true

	
	override init() {
		let defaults = UserDefaults.standard
		let libraryPath = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		let file = libraryPath.appendingPathComponent("Preferences").appendingPathComponent("org.wasters.Freecell.history.json")
		history = History.from(file)
		
		super.init()
		
		defaults.register(defaults: [historySortColumn: "date", historySortDescending: true])
	}
	
	override func awakeFromNib() {
		tableView.autosaveName = "history"
		tableView.autosaveTableColumns = true
		tableView.target = self
		tableView.doubleAction = #selector(HistoryController.retryGame(_:))
		
		sortColumn = UserDefaults.standard.string(forKey: historySortColumn)!
		sortDescending = UserDefaults.standard.bool(forKey: historySortDescending)
		sortTable()
		
		setDateFormat()
		
		updateWindow()
	}
	
	private func sortTable() {
		
	}
	
	private func setDateFormat() {
		
	}
	
	private func updateWindow() {
		
	}
	
	@IBAction func clear(_ sender: Any?) {
		
	}
	
	@IBAction func openWindow(_ sender: Any?) {
		
	}

	@IBAction func retryGame(_ sender: Any?) {
		
	}
	
	func addRecord(gameNumber: UInt64, result: Result, moves: Int, duration: TimeInterval, date: Date) {
		history.addRecord(gameNumber: gameNumber, result: result, moves: moves, duration: duration, date: date)
		sortTable()
		updateWindow()
	}
}
