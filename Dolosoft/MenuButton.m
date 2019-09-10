//
//  MenuButton.m
//  Dolosoft
//
//  Created by Moran, Ander on 9/10/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "MenuButton.h"

@implementation MenuButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    NSButtonCell *cell = self.cell;
    cell.backgroundColor = [NSColor controlBackgroundColor];
    return self;
}
@end
