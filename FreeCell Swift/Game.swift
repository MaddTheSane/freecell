//
//  Game.swift
//  FreeCell Swift
//
//  Created by C.W. Betts on 10/17/18.
//

import Cocoa

class Game {
	let table: Table
	let view: GameView
	let controller: GameController
	private(set) var move: TableMove?
	var hint: TableMove?
	private var played = [TableMove]()
	private var undone = [TableMove]()
	let gameNumber: UInt64
	var startDate = Date()
	var endDate: Date?
	private(set) var inProgress = false
	private(set) var result = Result.unplayed
	
	init(view newView: GameView, controller newController: GameController, gameNumber newGameNumber: UInt64) {
		view = newView
		controller = newController
		
		gameNumber = newGameNumber
		
		table = Table()
		
		dealCards()
		
		view.needsDisplay = true
	}
	
	func undo() {
		if let undo = played.last?.reversed {
			
			undone.append(undo)
			played.removeLast()
			table.move(undo)
			
			controller.moveMade()
			view.needsDisplay = true
		}
	}
	
	func redo() {
		if let redo = undone.last?.reversed {
			played.append(redo)
			undone.removeLast()
			table.move(redo)
			
			controller.moveMade()
			view.needsDisplay = true
		}
	}
	
	func clicked(_ location: TableLocation) {
		// If a move hasn't been started yet, and the location clicked can be
		// moved from (it's a free cell or a column), start the move.
		if move == nil {
			if (location.type == .freeCell || location.type == .column) && table.firstCard(at: location) != nil {
				move = TableMove(source: location)
				view.needsDisplay = true
			}
			return
		}
		
		// Otherwise, a move has been started, and this is the desired destination.
		move?.destination = location
		
		attemptMove()
	}
	
	func doubleClicked(_ location: TableLocation) {
		move = TableMove(source: location)
		//var card = table.firstCard(at: location)
		
		for i in 0 ..< NUMBER_OF_FREE_CELLS {
			let freeCell = TableLocation.init(type: .freeCell, number: UInt16(i))
			
			if table.firstCard(at: freeCell) == nil {
				move?.destination = freeCell
				break
			}
		}
		
		attemptMove()
	}

	func setHint() {
		/*
- (void) setHint
{
Card *card, *other;
TableLocation *source, *destination;
int i;

for (i = 0; i < NUMBER_OF_COLUMNS; i++)
{
unsigned j;

source = [TableLocation locationWithType: COLUMN number: i];
card = [table firstCardAtLocation: source];
for (j = 0; j < NUMBER_OF_STACKS; j++)
{
destination = [TableLocation locationWithType: STACK number: j];
other = [table firstCardAtLocation: destination];
if ([card isSuccessorTo: other])
goto foundHint;
}
for (j = 0; j < NUMBER_OF_COLUMNS; j++)
{
destination = [TableLocation locationWithType: COLUMN number: j];
other = [table firstCardAtLocation: destination];
if ([card isPlayableOn: other])
goto foundHint;
}
}

for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
{
unsigned j;

source = [TableLocation locationWithType: FREE_CELL number: i];
card = [table firstCardAtLocation: source];
for (j = 0; j < NUMBER_OF_STACKS; j++)
{
destination = [TableLocation locationWithType: STACK number: j];
other = [table firstCardAtLocation: destination];
if ([card isSuccessorTo: other])
goto foundHint;
}
for (j = 0; j < NUMBER_OF_COLUMNS; j++)
{
destination = [TableLocation locationWithType: COLUMN number: j];
other = [table firstCardAtLocation: destination];
if ([card isPlayableOn: other])
goto foundHint;
}
}

for (i = 0; i < NUMBER_OF_COLUMNS; i++)
{
unsigned j;

source = [TableLocation locationWithType: COLUMN number: i];
if ([table firstCardAtLocation: source] == nil)
continue;

for (j = 0; j < NUMBER_OF_FREE_CELLS; j++)
{
destination = [TableLocation locationWithType: FREE_CELL number: j];
if ([table firstCardAtLocation: destination] == nil)
goto foundHint;
}
}

// No hint found.
[self setHint: nil];

foundHint:
[self setHint: [TableMove moveFromSource: source toDestination: destination]];
}*/
	}
	
	private func dealCards() {
		let deckTableLocation = TableLocation(type: .deck, number: 0)
		
		// Shuffle the deck
		var shuffleRand = VCCRandomNumberGenerator(holdrand: gameNumber)
		table.shuffleDeck(using: &shuffleRand)
		let deck = table.array(for: deckTableLocation)!
		
		// Lay out table
		for i in 0 ..< deck.count {
			let column = TableLocation(type: .column, number: UInt16(i % NUMBER_OF_COLUMNS))
			table.move(TableMove(source: deckTableLocation, destination: column))
		}
	}
	
	private func attemptMove() {
		guard var move = move else {
			return
		}
		move.count = 0
		
		if move.source.type == .column && move.destination.type == .column {
			var emptyFreeCells = table.numberOfEmptyTableLocation(.freeCell)
			var emptyColumns = table.numberOfEmptyTableLocation(.column)
			
			// The maximum number of cards which may be played with F empty free
			// cells is F + 1. However, this is doubled for every empty column,
			// except for the destination column.
			if emptyColumns > 0 && table.cardNumber(1, at: move.destination) == nil {
				emptyColumns -= 1
			}
			
			// If super-move is disabled, just pretend there are no empty free cells or columns.
			if UserDefaults.standard.bool(forKey: "gameSuperMove") == false {
				emptyFreeCells = 0; emptyColumns = 0;
			}
			
			// So, the maximum number of cards is (F + 1) * 2^C, and
			// 2^C == 1 << C.
			for count in (0 ..< (emptyFreeCells + 1) * (1 << emptyColumns)).reversed() {
				// Check that the `count' cards are in valid sequence; break from the
				// loop if they are not.
				var try1 = count
				while try1 > 1 {
					if !(table.cardNumber(try1 - 1, at: move.source)?.isPlayable(on: table.cardNumber(try1, at: move.source)) ?? false) {
						break
					}
					
					try1 -= 1
				}

				// The condition `try == 1' is YES iff the card sequence is valid.
				if try1 == 1 && (table.cardNumber(count, at: move.source)?.isPlayable(on: table.firstCard(at: move.destination)) ?? false) {
					move.count = UInt32(count)
					break
				}
			}
		} else if move.destination.type == .stack {
			if table.firstCard(at: move.source)?.isSuccessor(to: table.firstCard(at: move.destination)) ?? false {
				move.count = 1
			}
		} else if move.destination.type == .column {
			if table.firstCard(at: move.source)?.isPlayable(on: table.firstCard(at: move.destination)) ?? false {
				move.count = 1
			}
		} else if move.destination.type == .freeCell {
			if table.array(for: move.destination)!.count == 0 {
				move.count = 1
			}
		}
		
		if move.count > 0 {
			if (inProgress == false) {
				inProgress = true;
				startDate = Date()
			}
			table.move(move)
			undone.removeAll()
			played.append(move)
			controller.moveMade()
		}
		
		self.move = nil
		view.needsDisplay = true
		moreMoves()
		if UserDefaults.standard.bool(forKey: "gameAutoStack") {
			autoStack()
		}
	}
	
	private func moreMoves() {
		var i = 0
		while i < NUMBER_OF_STACKS {
			if table.cardNumber(1, at: TableLocation(type: .stack, number: UInt16(i)))?.rank != .king {
				break
			}
			i += 1
		}
		
		if i == NUMBER_OF_STACKS {
			gameOver(with: .win)
			controller.gameOver()
			return
		}
		
		guard table.numberOfEmptyTableLocation(.freeCell) == 0 else {
			return
		}
		
		for i in 0 ..< NUMBER_OF_FREE_CELLS {
			guard let card = table.firstCard(at: TableLocation(type: .freeCell, number: UInt16(i))) else {
				continue
			}
			for j in 0 ..< NUMBER_OF_STACKS {
				let other = table.firstCard(at: TableLocation(type: .stack, number: UInt16(j)))
				if card.isSuccessor(to: other) {
					return;
				}
			}
			
			for j in 0 ..< NUMBER_OF_COLUMNS {
				let other = table.firstCard(at: TableLocation(type: .column, number: UInt16(j)))
				if card.isPlayable(on: other) {
					return
				}
			}
		}
		
		for i in 0 ..< NUMBER_OF_COLUMNS {
			guard let card = table.firstCard(at: TableLocation(type: .column, number: UInt16(i))) else {
				continue
			}
			for j in 0 ..< NUMBER_OF_STACKS {
				let other = table.firstCard(at: TableLocation(type: .stack, number: UInt16(j)))
				if card.isSuccessor(to: other) {
					return;
				}
			}
			
			for j in 0 ..< NUMBER_OF_COLUMNS {
				let other = table.firstCard(at: TableLocation(type: .column, number: UInt16(j)))
				if card.isPlayable(on: other) {
					return;
				}
			}
		}
		
		gameOver(with: .loss)
		controller.gameOver()
	}

	func autoStack() {
		
	
	
	/*
- (void) G_autoStack
{
unsigned i, minimumStackedRank;
TableLocation *source, *destination;
Card *card, *other;

minimumStackedRank = KING;
for (i = 0; i < NUMBER_OF_STACKS; i++)
{
TableLocation *stack = [TableLocation locationWithType: STACK number: i];
unsigned rank = [[table firstCardAtLocation: stack] rank];
if (rank < minimumStackedRank)
minimumStackedRank = rank;
}

for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
{
unsigned j;

source = [TableLocation locationWithType: FREE_CELL number: i];
card = [table firstCardAtLocation: source];

for (j = 0; j < NUMBER_OF_STACKS; j++)
{
destination = [TableLocation locationWithType: STACK number: j];
other = [table firstCardAtLocation: destination];
if ([card isSuccessorTo: other] && [card rank] < minimumStackedRank + 3)
goto makeMove;
}
}

for (i = 0; i < NUMBER_OF_COLUMNS; i++)
{
unsigned j;

source = [TableLocation locationWithType: COLUMN number: i];
card = [table firstCardAtLocation: source];

for (j = 0; j < NUMBER_OF_STACKS; j++)
{
destination = [TableLocation locationWithType: STACK number: j];
other = [table firstCardAtLocation: destination];
if ([card isSuccessorTo: other] && [card rank] < minimumStackedRank + 3)
goto makeMove;
}
}

// No safe auto-stack possible
return;

makeMove:
[self G_setMove: [TableMove moveFromSource: source toDestination: destination]];
[self G_attemptMove];
}

	*/
	
	}
	
	func gameOver(with newResult: Result) {
		endDate = Date()
		result = newResult
		inProgress = false
	}
	
	var moves: Int {
		return played.count
	}
	
	var duration: TimeInterval {
		return endDate?.timeIntervalSince(startDate) ?? 0
	}
	
	var canUndo: Bool {
		return inProgress && played.count > 0
	}
	
	var canRedo: Bool {
		return inProgress && undone.count > 0
	}

	func isSelected(_ card: Card) -> Bool {
		if let moveSrc = move?.source, let tableCard = table.firstCard(at: moveSrc) {
			if tableCard == card {
				return true
			}
		}
		if let hintSrc = hint?.source, let tableCard = table.firstCard(at: hintSrc) {
			if tableCard == card {
				return true
			}
		}
		if let hintDst = hint?.destination, let tableCard = table.firstCard(at: hintDst) {
			if tableCard == card {
				return true
			}
		}
		
		return false
	}
	
	func isSelected(_ location: TableLocation) -> Bool {
		if let moveSrc = move?.source {
			if moveSrc == location {
				return true
			}
		}
		if let hintSrc = hint?.source {
			if hintSrc == location {
				return true
			}
		}
		if let hintDst = hint?.destination {
			if hintDst == location {
				return true
			}
		}
		
		return false
	}
	
	var movesList: [String] {
		return played.map({$0.description})
	}
}
