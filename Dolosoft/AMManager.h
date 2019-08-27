//
//  AMManager.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/9/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAppManager.h"
#import "AMFileManager.h"
#import "AMConnectionHandler.h"
#import "AMTweakBuilder.h"
#import "AMLogger.h"
#import "AMDeviceManager.h"
#import "AMDevice.h"
#import "AMMainViewController.h"
#import "InitialViewController.h"
#import "DeviceInfoViewController.h"
#import "StringsViewController.h"

@class AMAppManager, AMClassDumpParser, AMTweakBuilder, AMFileManager, AMApp, AMLogger, AMObjcClass, AMDeviceManager, AMDevice, InitialViewController, DeviceInfoViewController, StringsViewController;


NS_ASSUME_NONNULL_BEGIN

@interface AMManager : NSObject {
    NSStoryboard *storyBoard;
    dispatch_group_t group;
    dispatch_queue_t background_queue;
}
@property(retain, nonatomic) AMAppManager *appManager;
@property(retain, nonatomic) AMFileManager *fileManager;
@property(retain, nonatomic) AMConnectionHandler *connectionHandler;
@property(retain, nonatomic) AMTweakBuilder *tweakBuilder;
@property(retain, nonatomic) AMLogger *logger;
@property(retain, nonatomic) AMDeviceManager *deviceManager;
@property(retain, nonatomic) AMDevice *device;
@property(retain, nonatomic) AMMainViewController *mainViewController;
@property(retain, nonatomic) InitialViewController *initialViewController;
@property(retain, nonatomic) DeviceInfoViewController *deviceInfoViewController;
@property(retain, nonatomic) StringsViewController *stringsViewController;
- (instancetype)init;
- (void)start;
- (void)setup;
- (void)checkForDevice;
- (void)deviceDidAttach;
- (BOOL)toolInstalled:(NSString *)toolName;
- (void)presentVCAsModal:(NSViewController *)viewController;
+ (NSString *)getSecureUserInput:(NSString *)prompt;
@end

NS_ASSUME_NONNULL_END
