//
//  AppsCollectionViewItem.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppsCollectionViewItem : NSCollectionViewItem
@property (strong) IBOutlet NSTextField *appNameLabel;
@property (strong) IBOutlet NSImageView *appIconView;
- (void)drawRect:(NSRect)dirtyRect;
@end

NS_ASSUME_NONNULL_END
