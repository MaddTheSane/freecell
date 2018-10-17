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
	@IBOutlet weak var gamesLost: NSTextField!
	@IBOutlet weak var gamesPlayed: NSTextField!
	@IBOutlet weak var gamesWon: NSTextField!
	@IBOutlet weak var retryGame: NSButton!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var lastPlayedColumn: NSTableColumn!
	//IBOutlet GameController *gameController;
	private let history: History
	private var sortColumn = "date"
	private var sortDescending = true

	
	override init() {
		let defaults = UserDefaults.standard
		let libraryPath = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		var file = libraryPath.appendingPathComponent("Preferences")
		file.appendPathComponent("com.github.MaddTheSane.FreeCell-Swift.history.json")
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
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .short
		(lastPlayedColumn.dataCell as? NSCell)?.formatter = formatter
	}
	
	private func updateWindow() {
		let won = history.numberOfRecords(with: .win)
		let lost = history.numberOfRecords(with: .loss)
		var wonPercent: Int
		var lostPercent: Int

		if won + lost == 0 {
			wonPercent = 0
			lostPercent = 0
		} else {
			wonPercent = Int(floor(( Double(won) * 100.0) / Double(won + lost)));
			lostPercent = 100 - wonPercent;
		}
		
		gamesPlayed.integerValue = won + lost
		gamesWon.stringValue = "\(won) (\(wonPercent)%)"
		gamesLost.stringValue = "\(lost) (\(lostPercent)%)"
		tableView.noteNumberOfRowsChanged()
		tableView.needsDisplay = true
	}
	
	@IBAction func clear(_ sender: Any?) {
		
	}
	
	@IBAction func openWindow(_ sender: Any?) {
		window.makeKeyAndOrderFront(self)
	}

	@IBAction func retryGame(_ sender: Any?) {
		
	}
	
	func addRecord(gameNumber: UInt64, result: Result, moves: Int, duration: TimeInterval, date: Date) {
		history.addRecord(gameNumber: gameNumber, result: result, moves: moves, duration: duration, date: date)
		sortTable()
		updateWindow()
	}
	
	// MARK: - NSTableViewDataSource
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		assert(tableView === self.tableView)
		return history.records.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		assert(tableView === self.tableView)
		guard let tableColumnIdentifier = tableColumn?.identifier, row < history.records.count else {
			return nil
		}
		let historyObj = history.records[row]
		switch tableColumnIdentifier {
		case NSUserInterfaceItemIdentifier("gameNumber"):
			return NSNumber(value: historyObj.gameNumber)
			
		case NSUserInterfaceItemIdentifier("result"):
			return historyObj.result.localizedDescription

		case NSUserInterfaceItemIdentifier("moves"):
			return historyObj.moves

		case NSUserInterfaceItemIdentifier("duration"):
			_="%H:%M:%S"
			return historyObj.duration

		case NSUserInterfaceItemIdentifier("date"):
			return historyObj.date

		default:
			return nil
		}
	}
	
	// MARK: - NSTableViewDelegate
}
