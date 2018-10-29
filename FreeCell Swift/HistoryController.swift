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
	@IBOutlet weak var gameController: GameController!
	private let history: History
	private var sortColumn = NSUserInterfaceItemIdentifier("date")
	private var sortDescending = true
	private var timeIntervalFormatter: DateComponentsFormatter = {
		let format = DateComponentsFormatter()
		format.zeroFormattingBehavior = [.pad]
		format.allowedUnits = [.hour, .minute, .second]
		return format
	}()
	
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
		
		sortColumn = NSUserInterfaceItemIdentifier(UserDefaults.standard.string(forKey: historySortColumn)!)
		sortDescending = UserDefaults.standard.bool(forKey: historySortDescending)
		sortTable()
		
		setDateFormat()
		
		updateWindow()
	}
	
	private func sortDescendingToImage() -> NSImage {
		if sortDescending {
			return NSImage(named: "NSDescendingSortIndicator")!
		} else {
			return NSImage(named: "NSAscendingSortIndicator")!
		}
	}
	
	private func sortTable() {
		let sortImage = sortDescendingToImage()
		let column = tableView.tableColumn(withIdentifier: sortColumn)!
		
		tableView.setIndicatorImage(sortImage, in: column)
		tableView.highlightedTableColumn = column
		
		history.sort(byIdentifier: sortColumn.rawValue, descending: sortDescending)
		tableView.reloadData()
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
		let alert = NSAlert()
		alert.addButton(withTitle: NSLocalizedString("cancelButton", comment: "Cancel button"))
		alert.addButton(withTitle: NSLocalizedString("clearButton", comment: "Clear history button"))
		alert.alertStyle = .warning
		alert.messageText = NSLocalizedString("clearTitle", comment: "Clear history sheet title")
		alert.informativeText = NSLocalizedString("clearText", comment: "Clear history sheet text")
		alert.beginSheetModal(for: window) { (returnCode) in
			if returnCode == .alertSecondButtonReturn {
				self.history.clear()
				self.updateWindow()
			}
		}
	}
	
	@IBAction func openWindow(_ sender: Any?) {
		window.makeKeyAndOrderFront(self)
	}

	@IBAction func retryGame(_ sender: Any?) {
		let row = tableView.selectedRow
		
		// Ignore double-clicks on the TableView if they are on a column header
		if (sender as AnyObject?) === tableView && tableView.clickedRow == -1 {
			return
		}
		
		guard row != -1 else {
			return
		}
		gameController.playGame(withNumber: history.gameNumber(forRecord: row)!)
		window.close()
	}
	
	func addRecord(gameNumber: UInt64, result: Result, moves: Int, duration: TimeInterval, date: Date) {
		history.addRecord(gameNumber: gameNumber, result: result, moves: moves, duration: duration, date: date)
		sortTable()
		updateWindow()
	}
	
	var shortestDuration: TimeInterval {
		return history.shortestDuration
	}
	
	var shortestMoves: Int {
		return history.shortestMoves
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
			return timeIntervalFormatter.string(from: historyObj.duration)

		case NSUserInterfaceItemIdentifier("date"):
			return historyObj.date

		default:
			return nil
		}
	}
	
	// MARK: - NSTableViewDelegate
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow == -1 {
			retryGame.isEnabled = false
		} else {
			retryGame.isEnabled = true
		}
	}
	
	func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
		let defaults = UserDefaults.standard
		if sortColumn == tableColumn.identifier {
			sortDescending = !sortDescending
		} else {
			tableView.setIndicatorImage(nil, in: tableView.tableColumn(withIdentifier: sortColumn)!)
			sortDescending = false
		}
		
		sortColumn = tableColumn.identifier
		sortTable()
		
		defaults.set(sortColumn.rawValue, forKey: historySortColumn)
		defaults.set(sortDescending, forKey: historySortDescending)
		defaults.synchronize()
	}
}
