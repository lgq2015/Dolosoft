//
//  StringsViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/14/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *stringsTableView;
}
@property(retain, nonatomic) NSArray *strings;
@end

NS_ASSUME_NONNULL_END
