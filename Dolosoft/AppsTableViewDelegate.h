//
//  AppsTableViewDelegate.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/14/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppsTableViewDelegate : NSObject<NSTableViewDelegate>
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
@end

NS_ASSUME_NONNULL_END
