//
//  InitialViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMDevice.h"
#import "AMDeviceManager.h"
#import "AMMainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AMDevice, AMMainViewController;

@interface InitialViewController : NSViewController
@property (strong) IBOutlet NSTextField *statusTextField;
@property (strong) IBOutlet NSProgressIndicator *waitingIndicator;
- (void)dismissSelfAndPresentMainVC:(AMMainViewController *)mainViewController;
- (void)deviceDidAttachWithName:(NSString *)name;
- (void)setStatus:(NSString *)status;
@end

NS_ASSUME_NONNULL_END
