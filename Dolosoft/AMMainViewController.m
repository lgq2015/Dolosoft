//
//  AMMainViewController.m
//  Dolosoft
//
//  Created by Ander Moran on 4/9/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMMainViewController.h"

/*
 starting a list of things that must be installed on the iOS device:
 scp
 defaults (from the package Cephei by HASHBANG productions)
 
*/
// https://medium.com/@airejie/setting-up-xcode-for-c-projects-17531c3c3941
// for getting libimobiledevice to import
// add the search paths for headers and libs

@implementation AMMainViewController
- (void)redirectLogToDocuments {
    #ifdef DEBUG
        return;
    #endif
    // https://stackoverflow.com/questions/7271528/how-to-nslog-into-a-file
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Target name"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dirPath = nil;
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:targetName];
    NSString *pathForLog = [NSString stringWithFormat:@"%@/liveTerminalLog.txt", [dirPath path]];
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

// NSAlert+SynchronousSheet.h (in case i need this later)
/*  TODO: Figure out how to make the initial UI load, so that I can look at the terminal feed.
    Once all the app data has been collected, then load the rest
 */
// https://stackoverflow.com/questions/54083843/how-can-i-get-the-ecid-of-a-connected-device-using-libimobiledevice
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self redirectLogToDocuments];

    self.view.layer.backgroundColor = [NSColor colorWithCalibratedRed:71.0f/255.0f
                                                                green:69.0f/255.0f
                                                                 blue:68.0f/255.0f
                                                                alpha:1].CGColor;
/* leaving these here in case I need to reset the defaults */
//        NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];

    if (!password) {
        password = [self getSecureUserInput:@"Enter iOS device root password" defaultValue:@""];
        [defaults setObject:password forKey:@"password"];
        [defaults synchronize];
    }

    fileManager = [[AMFileManager alloc] init];
    appManager = [[AMAppManager alloc] initWithFileManager:fileManager];
    appManager.mainViewController = self;
    tweakBuilder = [[AMTweakBuilder alloc] initWithFileManager:fileManager];
    tweakBuilder.mainViewController = self;
    logger = [[AMLogger alloc] initWithFileManager:fileManager];


    NSString *hostName = @"localhost";
    NSString *username = @"root";
    NSInteger port = 2222;
    connectionHandler = [[AMConnectionHandler alloc]
                         initWithHost:hostName
                         port:port
                         username:username
                         password:password];

    while (!connectionHandler.session.isConnected) {
        password = [self getSecureUserInput:@"Incorrect iOS device root password. Please try again" defaultValue:@""];
        [defaults setObject:password forKey:@"password"];
        [defaults synchronize];
        connectionHandler = [[AMConnectionHandler alloc]
                             initWithHost:hostName
                             port:port
                             username:username
                             password:password];
    }

    deviceManager = [[AMDeviceManager alloc] initWithConnectionHandler:connectionHandler fileManger:fileManager];

    if (connectionHandler.session.isConnected) {
        logger.connectionHandler = connectionHandler;

        if ([deviceManager toolsInstalled]) {
            NSLog(@"Dolosoft::DolosoftTools already installed on iOS device at /var/root/DolosoftTools");
        } else {
            [deviceManager installTools];
        }

        appManager.appList = [deviceManager getUserApps];
        [deviceManager addUserAppsDocumentsDirectory:appManager];

        [appsTableView setAction:@selector(tableViewClicked:)];
        [classesTableView setAction:@selector(tableViewClicked:)];
        [methodsTableView setAction:@selector(tableViewClicked:)];

        //        appsTableView.focusRingType = NSFocusRingTypeNone;
        //        classesTableView.focusRingType = NSFocusRingTypeNone;
        //        methodsTableView.focusRingType = NSFocusRingTypeNone;

        terminalTextView.editable = NO;
        terminalTextView.font = [NSFont fontWithName:@"Monaco" size:12];

        logTextView.editable = NO;
        logTextView.font = [NSFont fontWithName:@"Monaco" size:12];
        
        [connectedToLabel setStringValue:[NSString stringWithFormat:@"Connected to %@", _device.DeviceName]];

        [self updateTerminalDaemon];
    } else {
        NSLog(@"Dolosoft::Unable to establish connection.");
        NSLog(@"Dolosoft::%@", [connectionHandler.session.lastError localizedDescription]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Exit"];
        [alert setMessageText:[NSString stringWithFormat:@"Unable to connect to %@@%@ at port %ld\nMake sure device is connected via USB.",
                               username,
                               hostName,
                               (long)port]];
        [alert runModal];
    }
    
}

- (void)updateTerminalDaemon {
    //NSTimer calling check: every 1 second.
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self selector:@selector(updateTerminal:) userInfo:nil repeats:YES];
}

- (void)updateTerminal:(NSTimer *)timer {
    NSString *logPath = [NSString stringWithFormat:@"%@/liveTerminalLog.txt", [fileManager mainDirectoryPath]];
    NSString* content = [NSString stringWithContentsOfFile:logPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if (![content isEqualToString:[[terminalTextView textStorage] string]]) {
        [terminalTextView setString:content];
    }
}

- (IBAction)cycriptButtonClicked:(id)sender {
    NSString *loadCycriptPath = [NSString stringWithFormat:@"%@/loadCycript.sh", [fileManager mainDirectoryPath]];
    [[NSWorkspace sharedWorkspace] openFile:loadCycriptPath withApplication:@"Terminal"];
}
- (IBAction)SSHSessionButtonClicked:(id)sender {
    NSString *loadTerminalPath = [NSString stringWithFormat:@"%@/loadSSH.sh", [fileManager mainDirectoryPath]];
    [[NSWorkspace sharedWorkspace] openFile:loadTerminalPath withApplication:@"Terminal"];
}

- (IBAction)respringButtonClicked:(id)sender {
    NSError *error = nil;
    [connectionHandler.session.channel execute:@"killall -9 SpringBoard" error:&error];
}
- (IBAction)killAppButtonClicked:(id)sender {
    NSError *error = nil;
    NSString *command = [NSString stringWithFormat:@"killall -9 \"%@\"", selectedApp.executableName];
    [connectionHandler.session.channel execute:command error:&error];
}
- (IBAction)stringsButtonClicked:(id)sender {
    /* strings /path/to/executable */
    /* need todo this */
}

- (IBAction)clearLogButtonClicked:(id)sender {
    [logTextView setString:@""];
}

- (void)getAppLog {
    NSString *logPath = [NSString stringWithFormat:@"%@/AMLog.txt", [fileManager mainDirectoryPath]];
    [fileManager removeItemAtPath:logPath error:nil];
    [logTextView setString:[logger logForApp:selectedApp]];
}

- (IBAction)getLogButtonClicked:(id)sender {
    /* TODO: Make the log live update */
    //    NSTimer *timer;
    //    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
    //                                             target:self selector:@selector(getAppLog) userInfo:nil repeats:YES];
    [self getAppLog];
}

- (IBAction)installTweakButtonClicked:(id)sender {
    if ([fileManager fileExistsAtPath:selectedApp.tweakDirPath isDirectory:nil]) {
        [tweakBuilder makeDoTheosForApp:[appManager appWithDisplayName:selectedApp.displayName]];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"No tweak to install. You must create a tweak before installing."];
        [alert runModal];
    }
}

- (IBAction)editTweakButtonClicked:(id)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[selectedApp tweakFilePath]]) {
        [[NSWorkspace sharedWorkspace] openFile:[selectedApp tweakFilePath] withApplication:@"Xcode"];
    }
}

- (IBAction)analyzeAppButtonClicked:(id)sender {
    // lifesaver: https://stackoverflow.com/questions/16283652/understanding-dispatch-async?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    
    selectedClass = nil; // This is because I need to clear the methods table view after a new app selected
    
    if (appsTableView.selectedRow == -1) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"No app selected"];
        [alert runModal];
        return;
    }
    
    selectedApp = [appManager
                   appWithDisplayName:appManager.appList[appsTableView.selectedRow].displayName];
    NSLog(@"selectedApp = %@", [selectedApp displayName]);
    
    /* this line below is used for interdevice communication between macOS and iOS so that cycript can launch with the executableName for the -p argument */
    [selectedApp.executableName writeToFile:[NSString stringWithFormat:@"%@/selectedApp.txt",
                                             [fileManager mainDirectoryPath]]
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:nil];
    
    /*  had to remove this because it broke the program whenever I selected a class in one app and then switched to another.
     problem is when the index selected is higher than the maximum number of classes in the new app
     */
    //    NSAlert *alert = [[NSAlert alloc] init];
    //    [alert addButtonWithTitle:@"Continue"];
    //    [alert setMessageText:@"Before preceding..."];
    //    [alert setInformativeText:[NSString stringWithFormat:@"Please open %@ on your iOS device", selectedApp.displayName]];
    //    [alert setAlertStyle:NSAlertStyleCritical];
    //    [alert runModalSheet];
    
    
    [classesTableView reloadData];
    [methodsTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        /* check to see if we have decrypted file or headers */
        if (![fileManager fileExistsAtPath:[fileManager pathOfDecryptedBinaryForApp:selectedApp]] &&
            ![fileManager fileExistsAtPath:[fileManager pathOfHeaderForApp:selectedApp]]) {
            NSLog(@"AM::App has not been decrypted and/or downloaded. Decrypting and downloading now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Decrypting app"];
                [analyzeAppProgressLabel display];
            });
            [deviceManager decryptAppAndDownload:selectedApp];
        }
        
        if (![fileManager fileExistsAtPath:[fileManager pathOfHeaderForApp:
                                            selectedApp]]) {
            NSLog(@"headerPath = %@", selectedApp.headerPath);
            NSLog(@"AM::Headers have not been dumped. Dumping now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Dumping headers"];
                [analyzeAppProgressLabel display];
            });
            [appManager dumpHeadersForApp:selectedApp];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [analyzeAppProgressLabel setStringValue:@"Parsing headers"];
            [analyzeAppProgressLabel display];
        });
        
        //NSLog(@"LABEL = %@", [analyzeAppProgressLabel di]);
        [appManager initializeClassListForApp:selectedApp];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [analyzeAppProgressLabel setStringValue:@"Analysis finished"];
            [classesTableView reloadData];
            [methodsTableView reloadData];
        });
        
    });
    
}

- (IBAction)removeTweakButtonClicked:(id)sender {
    NSError *error = nil;
    NSString *command = [NSString stringWithFormat:@"printf \"Y\" | apt-get remove com.dolosoft.dolosoft-%@",
                         selectedApp.displayNameLowercaseNoSpace];
    [connectionHandler.session.channel execute:command error:&error];
}

- (IBAction)createTweakButtonClicked:(id)sender {
    [createTweakProgressBar setUsesThreadedAnimation:YES];
    [createTweakProgressBar startAnimation:nil];
    
    // Collect all the methods to we want
    NSMutableArray<AMObjcMethod *> *methods = [[NSMutableArray alloc] init];
    [methodsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = selectedClass.methodsList[index];
        [methods addObject:objcMethod];
    }];
    
    [tweakBuilder createTheosProjectForApp:selectedApp];
    [tweakBuilder writeTweakCodeForApp:selectedApp forObjcClass:selectedClass withMethods:methods];
    
    [createTweakProgressBar stopAnimation:nil];
}

- (void)keyDown:(NSEvent *)event {
    // https://stackoverflow.com/questions/4668847/nstableview-delete-key
    
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if ((key == NSEnterCharacter || key == NSCarriageReturnCharacter)
        && NSView.focusView == appsTableView) {
        [analyzeAppButton performClick:self];
    }
}

/*  Used to handle user clicking on class name but now
 I just use tableViewSelectionDidChange:notification
 because it handles the user changing the class by
 using the arrow keys as well
 
 Leaving here for now because of the TODO inside of it
 and in case I need this method to implement said TODO
 */
- (void)tableViewClicked:(id)sender {
    NSTableView *tableView = sender;
    tableView.lockFocus; // Need this code so we know how to handle the user pressing the return key
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    if (tableView.selectedRow != -1) {
        if (tableView == classesTableView) {
            selectedClass = [selectedApp classWithName:selectedApp.classList[tableView.selectedRow].className];
            [methodsTableView reloadData];
        } else if (tableView == appsTableView) {
            selectedApp = [appManager appWithDisplayName:appManager.appList[appsTableView.selectedRow].displayName];
            selectedClass = nil;
            [classesTableView reloadData];
            [methodsTableView reloadData];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == appsTableView) {
        return [appManager.appList count];
    } else if (tableView == classesTableView) {
        return [selectedApp.classList count];
    } else if (tableView == methodsTableView) {
        return [selectedClass.methodsList count];
    } else {
        return 0;
    }
}

// TODO: Color code the methods! It's hard to search

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"apps"]) {
        AMApp *app = [appManager.appList objectAtIndex:rowIndex];
        return app.displayName;
    } else if ([identifier isEqualToString:@"classes"]) {
        return selectedApp.classList[rowIndex].className;
    } else if ([identifier isEqualToString:@"methods"]) {
        return selectedClass.methodsList[rowIndex].callSyntax;
    } else {
        return @"THIS SHOULD NEVER RETURN";
    }
}

- (NSString *)getSecureUserInput:(NSString *)prompt defaultValue:(NSString *)defaultValue {
    // https://stackoverflow.com/questions/7387341/how-to-create-and-get-return-value-from-cocoa-dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:prompt];
    [alert addButtonWithTitle:@"Ok"];
    
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        return [input stringValue];
    } else {
        return nil;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
@end
