//
//  CardView.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Sun Jul 06 2003.
//  Copyright (c) 2003 Alisdair McDiarmid. All rights reserved.
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

#import <AppKit/NSStringDrawing.h>
#import <AppKit/AppKit.h>
#import "CardView.h"


@implementation CardView

+ cardView
{
    return [[CardView alloc] init];
}

- init
{
    if (self = [super init]) {
        @autoreleasepool {
            [self drawBlanks];
            [self drawCards];
            [self drawSelectedCards];
        }
    }
	
    return self;
}

- (void) drawBlanks
{
    NSImage *bonded = [NSImage imageNamed: @"bonded"];
    NSSize bondedSize = [bonded size];
    NSRect source;
    NSBitmapImageRep *card1x, *card2x;

    cardSize = NSMakeSize(bondedSize.width / 13, bondedSize.height / 5);
    
    // Placeholder blank
    blank = [[NSImage alloc] initWithSize: cardSize];
    source = NSMakeRect(0, bondedSize.height - 5 * cardSize.height,
                        cardSize.width, cardSize.height);
    card1x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:cardSize.width pixelsHigh:cardSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    card2x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:((NSInteger)cardSize.width)*2 pixelsHigh:((NSInteger)cardSize.height)*2 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    card2x.size = cardSize;

    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card1x];
	[bonded drawAtPoint: NSZeroPoint
			   fromRect: source
			  operation: NSCompositingOperationCopy fraction:1];
    [NSGraphicsContext.currentContext flushGraphics];

    NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card2x];
    [bonded drawAtPoint: NSZeroPoint
               fromRect: source
              operation: NSCompositingOperationCopy fraction:1];
    [NSGraphicsContext.currentContext flushGraphics];

    
    [blank addRepresentations:@[card1x, card2x]];
    
    // Selected blank (for placeholders and compositing selected cards)
    selectedBlank = [[NSImage alloc] initWithSize: cardSize];
    source = NSMakeRect(cardSize.width, bondedSize.height - 5 * cardSize.height,
                        cardSize.width, cardSize.height);
    
    card1x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:cardSize.width pixelsHigh:cardSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    card2x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:((NSInteger)cardSize.width)*2 pixelsHigh:((NSInteger)cardSize.height)*2 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    card2x.size = cardSize;

    NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card1x];
	[bonded drawAtPoint: NSZeroPoint
			   fromRect: source
			  operation: NSCompositingOperationCopy fraction: 1];
    
    NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card2x];
    [bonded drawAtPoint: NSZeroPoint
               fromRect: source
              operation: NSCompositingOperationCopy fraction:1];
    [NSGraphicsContext.currentContext flushGraphics];

    
    [selectedBlank addRepresentations:@[card1x, card2x]];
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawCards
{
    NSImage *bonded = [NSImage imageNamed: @"bonded"];
    NSImage *card;
    NSRect source;
    NSSize bondedSize = [bonded size];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 52];
    
    for (unsigned i = 0; i < NUMBER_OF_SUITS; i++) @autoreleasepool
    {
        for (unsigned j = ACE; j <= KING; j++)
        {
            card = [[NSImage alloc] initWithSize: cardSize];
            source = NSMakeRect((j - 1) * cardSize.width,
                                       bondedSize.height - (i + 1) * cardSize.height,
                                       cardSize.width, cardSize.height);
            
            NSBitmapImageRep *card1x, *card2x;
            card1x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:cardSize.width pixelsHigh:cardSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
            card2x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:((NSInteger)cardSize.width)*2 pixelsHigh:((NSInteger)cardSize.height)*2 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
            card2x.size = cardSize;

            [NSGraphicsContext saveGraphicsState];
            NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card1x];
            [bonded drawAtPoint: NSZeroPoint
                       fromRect: source
                      operation: NSCompositingOperationCopy fraction:1];
            [NSGraphicsContext.currentContext flushGraphics];
            
            NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card2x];
            [bonded drawAtPoint: NSZeroPoint
                       fromRect: source
                      operation: NSCompositingOperationCopy fraction:1];
            [NSGraphicsContext.currentContext flushGraphics];

            [NSGraphicsContext restoreGraphicsState];
            
            [card addRepresentations:@[card1x, card2x]];
            
            [dict setObject: card forKey: [Card cardWithSuit: i rank: j]];
        }
    }
    
    cards = dict;
}

- (void) drawSelectedCards
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 52];
    NSEnumerator *enumerator = [cards keyEnumerator];

    for (Card *card in enumerator)
    {
        NSBitmapImageRep *card1x, *card2x;
        card1x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:cardSize.width pixelsHigh:cardSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
        card2x = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:((NSInteger)cardSize.width)*2 pixelsHigh:((NSInteger)cardSize.height)*2 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
        card2x.size = cardSize;
        
        NSImage *cardImage = [cards objectForKey: card];
        NSImage *selectedCardImage = [[NSImage alloc] initWithSize: cardSize];
        [NSGraphicsContext saveGraphicsState];
        NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card1x];
        [cardImage drawAtPoint: NSMakePoint(0, 0) fromRect: NSZeroRect
                     operation: NSCompositeCopy fraction: 1.0];
        [selectedBlank drawAtPoint: NSMakePoint(0, 0) fromRect: NSZeroRect
                         operation: NSCompositeSourceAtop fraction: 0.5];
        [NSGraphicsContext.currentContext flushGraphics];
        
        NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:card2x];
        [cardImage drawAtPoint: NSMakePoint(0, 0) fromRect: NSZeroRect
                     operation: NSCompositeCopy fraction: 1.0];
        [selectedBlank drawAtPoint: NSMakePoint(0, 0) fromRect: NSZeroRect
                         operation: NSCompositeSourceAtop fraction: 0.5];
        [NSGraphicsContext.currentContext flushGraphics];

        [NSGraphicsContext restoreGraphicsState];
        [selectedCardImage addRepresentations:@[card1x, card2x]];
        [dict setObject: selectedCardImage forKey: card];        
    }
    selectedCards = dict;
}


- (NSImage *) imageForCard: (Card *) card selected: (BOOL) isSelected
{
    if (card == nil)
        return isSelected? selectedBlank: blank;
    
    return [isSelected? selectedCards: cards objectForKey: card];
}

@synthesize size=cardSize;

- (unsigned) overlap
{
    return cardSize.height/3;
}

- (unsigned) smallOverlap
{
    return cardSize.height/4.75;
}

@end
