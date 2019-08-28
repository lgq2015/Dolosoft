//
//  AppsCollectionView.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AppsCollectionView.h"

@implementation AppsCollectionView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)keyDown:(NSEvent *)event {
    // https://stackoverflow.com/questions/4668847/nstableview-delete-key
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSEnterCharacter || key == NSCarriageReturnCharacter) {
        [NSApplication.sharedApplication sendAction:@selector(analyzeAppButtonClicked:)
                                                 to:_manager.appsViewController
                                               from:self];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    // https://stackoverflow.com/questions/14574334/double-click-in-nscollectionview
    [super mouseDown:theEvent];
    if (theEvent.clickCount > 1) { // we assume if the user clicks more than once it's a double click
        [NSApplication.sharedApplication sendAction:@selector(analyzeAppButtonClicked:)
                                                 to:_manager.appsViewController
                                               from:self];
    }
}
@end
