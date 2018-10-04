//
//  HistoryController.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Tue Jul 29 2003.
//  Copyright (c) 2003 Alisdair McDiarmid.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
//  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  ALISDAIR MCDIARMID BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "HistoryController.h"
#import "GameController.h"

@interface HistoryController (PrivateMethods)

- (void) HC_updateWindow;
- (void) HC_sortTable;
- (void) HC_setSortColumn: (NSString *) newSortColumn;
- (NSImage *) HC_sortDescendingToImage;
- (void) HC_setDateFormat;

@end

@implementation HistoryController

// Overridden methods
//

- (void) awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *file = [[libraryPaths lastObject] stringByAppendingPathComponent:@"Preferences/org.wasters.Freecell.history.plist"];
    history = [[History alloc] initWithFile: file];

    [tableView setDataSource: history];
    [tableView setAutosaveName: @"history"];
    [tableView setAutosaveTableColumns: YES];
    [tableView setTarget: self];
    [tableView setDoubleAction: @selector(retryGame:)];

    [defaults registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"date", @"historySortColumn",
            [NSNumber numberWithBool: YES], @"historySortDescending",
            nil]];

    [self HC_setSortColumn: [defaults stringForKey: @"historySortColumn"]];
    sortDescending = [defaults boolForKey: @"historySortDescending"];
    [self HC_sortTable];

    [self HC_setDateFormat];
    
    [self HC_updateWindow];
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    if ([tableView selectedRow] == -1)
        [retryGame setEnabled: NO];
    else
        [retryGame setEnabled: YES];
}

- (void) tableView: (NSTableView *) newTableView didClickTableColumn: (NSTableColumn *) column
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([sortColumn isEqualToString: [column identifier]])
        sortDescending = !sortDescending;
    else
    {
        [tableView setIndicatorImage: nil
                       inTableColumn: [tableView tableColumnWithIdentifier: sortColumn]];
        sortDescending = NO;
    }

    [self HC_setSortColumn: [column identifier]];
    [self HC_sortTable];

    [defaults setObject: sortColumn forKey: @"historySortColumn"];
    [defaults setObject: [NSNumber numberWithBool: sortDescending] forKey: @"historySortDescending"];
    [defaults synchronize];
}

// Private methods
//

- (void) HC_updateWindow
{
    NSUInteger won  = [history numberOfRecordsWithResult: [Result resultWithWin]];
    NSUInteger lost = [history numberOfRecordsWithResult: [Result resultWithLoss]];
    NSUInteger wonPercent = (NSUInteger) floor(((double) won * 100.0) / (won + lost));
    NSUInteger lostPercent = 100 - wonPercent;
    
    if (won + lost == 0)
        wonPercent = lostPercent = 0.0;
    
    [gamesPlayed setIntegerValue: won + lost];
	[gamesWon    setStringValue: [NSString stringWithFormat: @"%lu (%lu%%)",
								  (unsigned long)won, (unsigned long)wonPercent]];
	[gamesLost    setStringValue: [NSString stringWithFormat: @"%lu (%lu%%)",
								   (unsigned long)lost, (unsigned long)lostPercent]];

    [tableView noteNumberOfRowsChanged];
    [tableView setNeedsDisplay: YES];
}

- (void) HC_sortTable
{
    NSImage *sortImage = [self HC_sortDescendingToImage];
    NSTableColumn *column = [tableView tableColumnWithIdentifier: sortColumn];
    
    [tableView setIndicatorImage: sortImage inTableColumn: column];
    [tableView setHighlightedTableColumn: column];

    [history sortByColumn: sortColumn withDescending: sortDescending];
    [tableView reloadData];
}

- (void) HC_setSortColumn: (NSString *) newSortColumn
{
    sortColumn = [newSortColumn copy];
}

- (NSImage *) HC_sortDescendingToImage
{
    if (sortDescending)
        return [NSImage imageNamed: @"NSDescendingSortIndicator"];
    else
        return [NSImage imageNamed: @"NSAscendingSortIndicator"];
}

- (void) HC_setDateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterShortStyle];
    [[lastPlayedColumn dataCell] setFormatter: formatter];
}

// Action methods
//

- (IBAction) clear: (id) sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: NSLocalizedString(@"cancelButton", @"Cancel button")];
    [alert addButtonWithTitle: NSLocalizedString(@"clearButton", @"Clear history button")];
    [alert setMessageText: NSLocalizedString(@"clearTitle", @"Clear history sheet title")];
    [alert setInformativeText: NSLocalizedString(@"clearText", @"Clear history sheet text")];
    [alert setAlertStyle: NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(clearSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) clearSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertSecondButtonReturn) {
        [history clear];
        [self HC_updateWindow];
    }
}

- (IBAction) openWindow: (id) sender
{
    [window makeKeyAndOrderFront: self];
}

- (IBAction) retryGame: (id) sender
{
    NSInteger row = [tableView selectedRow];

    // Ignore double-clicks on the TableView if they are on a column header
    if (sender == tableView && [tableView clickedRow] == -1)
        return;
    
    if (row != -1)
    {
        [gameController playGameWithNumber: [history gameNumberForRecord: row]];
        [window close];
    }
}

// Mutators
//

- (void) addRecordWithGameNumber: (NSNumber *) gameNumber
                          result: (Result *) result
                           moves: (NSUInteger) moves
                        duration: (NSTimeInterval) duration
                            date: (NSDate *) date
{
    [history addRecordWithGameNumber: gameNumber result: result moves: moves
                            duration: duration date: date];
    [self HC_sortTable];
    [self HC_updateWindow];
}

- (NSDate *) shortestDuration
{
    return [history shortestDuration];
}

- (NSUInteger) shortestMoves
{
    return [history shortestMoves];
}

- (NSUInteger) numberOfGamesWon
{
    return [history numberOfRecordsWithResult: [Result resultWithWin]];
}

@end
