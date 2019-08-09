//
//  InitialLoadingViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMDevice.h"

NS_ASSUME_NONNULL_BEGIN

@class AMDevice;

@interface InitialLoadingViewController : NSViewController
@property (strong) IBOutlet NSProgressIndicator *waitingIndicator;
@property (retain, nonatomic) AMDevice *device;
@end

NS_ASSUME_NONNULL_END
