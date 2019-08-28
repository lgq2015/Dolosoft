//
//  AppsCollectionViewItem.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AppsCollectionViewItem.h"

@implementation AppsCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.view.layer.backgroundColor = [NSColor selectedContentBackgroundColor].CGColor;
        self.appNameLabel.textColor = [NSColor selectedMenuItemTextColor];
    } else {
        self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
        self.appNameLabel.textColor = [NSColor labelColor];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
}
@end
