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
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
//#import "NSAlert+SynchronousSheet.h"


@class AMAppManager, AMClassDumpParser, AMTweakBuilder, AMFileManager, AMApp, AMLogger, AMObjcClass, AMDeviceManager;

@interface AMMainViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    AMAppManager *appManager;
    AMFileManager *fileManager;
    AMConnectionHandler *connectionHandler;
    AMApp *selectedApp;
    AMObjcClass *selectedClass;
    AMTweakBuilder *tweakBuilder;
    AMLogger *logger;
    AMDeviceManager *deviceManager;
    
    IBOutlet NSButton *analyzeAppButton;
    IBOutlet NSTextField *analyzeAppProgressLabel;
    IBOutlet NSProgressIndicator *analyzeAppProgressBar;
    IBOutlet NSProgressIndicator *createTweakProgressBar;
    IBOutlet NSTextView *logTextView;
    IBOutlet NSTableView *classesTableView;
    IBOutlet NSTableView *appsTableView;
    IBOutlet NSTableView *methodsTableView;
    IBOutlet NSTextView *terminalTextView;
}
@end

