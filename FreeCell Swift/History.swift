//
//  History.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/17/18.
//

import Cocoa

class History: NSObject, Codable {
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
		super.init()
	}
	
	func addRecord(gameNumber: UInt64, result: Result, moves: Int, duration: TimeInterval, date: Date) {
		
	}
	
	func numberOfRecords(with result: Result) -> Int {
		let filtered = records.filter({$0.result == result})
		return filtered.count
	}
}
