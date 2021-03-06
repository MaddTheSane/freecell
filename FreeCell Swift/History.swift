//
//  History.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/17/18.
//

import Cocoa

final class History: Codable {
	struct Object: Codable {
		var gameNumber: UInt64
		var result: Result
		var moves: Int
		var duration: TimeInterval
		var date: Date
	}
	
	private var file: URL
	private(set) var records: [History.Object]
	
	static func from(_ fileURL: URL) -> History {
		do {
			let fileData = try Data(contentsOf: fileURL)
			let aDec = JSONDecoder()
			let aHist = try aDec.decode(History.self, from: fileData)
			aHist.file = fileURL
			return aHist
		} catch {
			return History(internalFileURL: fileURL)
		}
	}
	
	init(internalFileURL fileURL: URL) {
		file = fileURL
		records = []
	}
	
	private func writeData() throws {
		let enc = JSONEncoder()
		let dat = try enc.encode(self)
		try dat.write(to: file)
	}
	
	func addRecord(gameNumber: UInt64, result: Result, moves: Int, duration: TimeInterval, date: Date) {
		records.append(History.Object(gameNumber: gameNumber, result: result, moves: moves, duration: duration, date: date))
		do {
			try writeData()
		} catch _ { }
	}
	
	func clear() {
		records.removeAll()
		do {
			try writeData()
		} catch _ { }
	}
	
	func numberOfRecords(with result: Result) -> Int {
		let filtered = records.filter({$0.result == result})
		return filtered.count
	}
	
	func sort(by byIdentifier: NSUserInterfaceItemIdentifier, descending: Bool) {
		switch byIdentifier {
		case gameNumberIdentifier:
			records.sort { (lhs, rhs) -> Bool in
				lhs.gameNumber < rhs.gameNumber
			}
			
		case movesIdentifier:
			records.sort { (lhs, rhs) -> Bool in
				lhs.moves < rhs.moves
			}
			
		case resultIdentifier:
			records.sort { (lhs, rhs) -> Bool in
				lhs.result < rhs.result
			}

		case durationIdentifier:
			records.sort { (lhs, rhs) -> Bool in
				lhs.duration < rhs.duration
			}

		case dateIdentifier:
			records.sort { (lhs, rhs) -> Bool in
				lhs.date < rhs.date
			}

		default:
			return
		}
		
		if descending {
			records.reverse()
		}
	}
	
	var shortestDuration: TimeInterval {
		var durations = records.compactMap { (anObj) -> TimeInterval? in
			guard anObj.result == .win else {
				return nil
			}
			return anObj.duration
		}
		durations.sort(by: <)
		
		return durations.first ?? 0
	}
	
	var shortestMoves: Int {
		var moves = records.compactMap { (anObj) -> Int? in
			guard anObj.result == .win else {
				return nil
			}
			return anObj.moves
		}
		moves.sort(by: <)
		
		return moves.first ?? 0
	}
	
	func record(_ n: Int) -> Object? {
		guard n < records.count else {
			return nil
		}
		return records[n]
	}
	
	func gameNumber(forRecord n: Int) -> UInt64? {
		return record(n)?.gameNumber
	}
	
	func record(gameNumber: UInt64) -> Object? {
		return records.first(where: {$0.gameNumber == gameNumber})
	}
}
