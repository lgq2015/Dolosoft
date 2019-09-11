//
//  AMMainViewController.h
//  Dolosoft
//
//  Created by Ander Moran on 4/9/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "AMConnectionHandler.h"
#import "AMFileManager.h"
#import "AMApp.h"
#import "AMObjcClass.h"
#import "AMClassDumpParser.h"
#import "AMAppManager.h"
#import "AMTweakBuilder.h"
#import "AMLogger.h"
#import "AMDeviceManager.h"
#import "AMDevice.h"
#import "InitialViewController.h"
#import "AMManager.h"


@class AMAppManager, AMClassDumpParser, AMTweakBuilder, AMFileManager, AMApp, AMLogger, AMObjcClass, AMDeviceManager, AMDevice, AMManager;

@interface AMMainViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTextField *connectedToLabel;
    IBOutlet NSTextField *analyzeAppProgressLabel;
    IBOutlet NSProgressIndicator *analyzeAppProgressBar;
    IBOutlet NSProgressIndicator *createTweakProgressBar;
    IBOutlet NSTextView *logTextView;
    IBOutlet NSTableView *classesTableView;
    IBOutlet NSTableView *methodsTableView;
    IBOutlet NSButton *consoleButton;
    IBOutlet NSButton *iOSApplicationLogButton;
    IBOutlet NSTableView *selectedMethodsTableView;
}
@property (strong) IBOutlet NSTextView *consoleTextView;
@property (strong) IBOutlet NSTextField *targetAppLabel;
@property(retain, nonatomic) AMManager *manager;
- (void)analyzeApp;
@end

