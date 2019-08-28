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
    } else {
        self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
}
@end
