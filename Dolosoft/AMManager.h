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

@class AMAppManager, AMClassDumpParser, AMTweakBuilder, AMFileManager, AMApp, AMLogger, AMObjcClass, AMDeviceManager, AMDevice, InitialViewController;


NS_ASSUME_NONNULL_BEGIN

@interface AMManager : NSObject {
    NSStoryboard *storyBoard;
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

- (instancetype)init;
- (void)setup; // TODO: rename this or restructure
- (void)start;
- (void)deviceDidConnect;
- (void)checkForDevice;
+ (NSString *)getSecureUserInput:(NSString *)prompt defaultValue:(NSString *)defaultValue;
@end

NS_ASSUME_NONNULL_END
