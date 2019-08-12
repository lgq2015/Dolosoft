//
//  DeviceInfoViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/12/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *deviceInfoTableView;
}
@property(retain, nonatomic) NSDictionary *deviceInfo;
@end

NS_ASSUME_NONNULL_END
