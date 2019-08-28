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
        // Add code here to simulate clicking the "Analyze app" button
    }
}
@end
