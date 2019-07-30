//
//  AMMainViewController.m
//  re_proj
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

@implementation AMMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"password" ofType:@"txt"];
    NSString *password = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    

    NSLog(@"HERE");
    self.view.layer.backgroundColor = [NSColor colorWithCalibratedRed:71.0f/255.0f
                                                                green:69.0f/255.0f
                                                                 blue:68.0f/255.0f
                                                                alpha:1].CGColor;
    if (!password) {
        NSLog(@"%@", error);
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Exit"];
        [alert setMessageText:@"password.txt does not exist"];
        
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [NSApp terminate:self];
        }
    } else if ([password length] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Exit"];
        [alert setMessageText:@"password.txt is empty. Please put the root password for your iOS device in password.txt"];
        
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [NSApp terminate:self];
        }
    }
    
    appManager = [[AMAppManager alloc] init];
    appManager.mainViewController = self;
    fileManager = [[AMFileManager alloc] init];
    tweakBuilder = [[AMTweakBuilder alloc] init];
    tweakBuilder.mainViewController = self;
    logger = [[AMLogger alloc] init];


    connectionHandler = [[AMConnectionHandler alloc]
                                              initWithHost:@"localhost"
                                                      port:2222
                                                  username:@"root"
                                                  password:password];

    if (connectionHandler.session.isConnected) {
        logger.connectionHandler = connectionHandler;
        
        NSString *response = [connectionHandler.session.channel
                              execute:@"if [ ! -d /var/root/DolosoftTools ]; then echo '/var/root/DolosoftTools does not exist'; fi"
                              error:nil];
        
        
        /* TODO: move this to AMFileManger class */
        if ([response isEqualToString:@"/var/root/DolosoftTools does not exist\n"]) {
            NSLog(@"/var/root/DolosoftTools does not exist on iOS device. Uploading them now.");
            [connectionHandler.session.channel
             execute:@"mkdir /var/root/DolosoftTools"
             error:nil];
            
            BOOL success_userapps = [connectionHandler.session.channel
                                     uploadFile:[NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]
                                     to:@"/var/root/DolosoftTools/"];
            if (success_userapps) {
                NSLog(@"Uploaded %@ to /var/root/DolosoftTools/userapps.sh on iOS device",
                      [NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]);
                [connectionHandler.session.channel
                 execute:@"chmod +x /var/root/DolosoftTools/userapps.sh"
                 error:nil];
            } else {
                NSLog(@"Failed to upload %@ to /var/root/DolosoftTools/userapps.sh on iOS device",
                      [NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]);
            }
            
            BOOL success_userappsextended = [connectionHandler.session.channel
                                             uploadFile:[NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]
                                             to:@"/var/root/DolosoftTools/"];
            if (success_userappsextended) {
                NSLog(@"Uploaded %@ to /var/root/DolosoftTools/userappsextended.sh on iOS device",
                      [NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]);
                [connectionHandler.session.channel
                 execute:@"chmod +x /var/root/DolosoftTools/userappsextended.sh"
                 error:nil];
            } else {
                NSLog(@"Failed to upload %@ to /var/root/DolosoftTools/userappsextended.sh on iOS device",
                      [NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]);
            }
        }
        /* end of TODO */


        appManager.appList = [self getUserAppsForSession:connectionHandler.session];
        [self addUserAppsDocumentsDirectory];

        [appsTableView setAction:@selector(tableViewClicked:)];
        [classesTableView setAction:@selector(tableViewClicked:)];
        [methodsTableView setAction:@selector(methodsTableViewClicked:)];


        terminalTextView.editable        = NO;
        terminalTextView.drawsBackground = NO;

        terminalTextView.backgroundColor = [NSColor colorWithCalibratedRed:45.0f/255.0f
                                                                     green:51.0f/255.0f
                                                                      blue:63.0f/255.0f
                                                                     alpha:1];

        terminalTextView.textColor = [NSColor whiteColor];
        terminalTextView.font = [NSFont fontWithName:@"Monaco" size:12];
        
        logTextView.textColor = [NSColor blackColor];
        logTextView.font = [NSFont fontWithName:@"Monaco" size:12];


        [self updateTerminalDaemon];
    } else {
        NSLog(@"Unable to establish connection.");
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

// TODO: pipe the output from the native Xcode terminal into terminalTextView window
//       so that the user can see errors when building w theos :)

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
    /* need to do this */
}

- (IBAction)clearLogButtonClicked:(id)sender {
    [logTextView setString:@""];
}

- (IBAction)getLogButtonClicked:(id)sender {
//    NSLog(@"AM::getLogButtonClicked");
    NSString *logPath = [NSString stringWithFormat:@"%@/AMLog.txt", [fileManager mainDirectoryPath]];
    [fileManager removeItemAtPath:logPath error:nil];
    [logTextView setString:[logger logForApp:selectedApp]];
}

- (IBAction)buildTweakButtonClicked:(id)sender {
    [tweakBuilder makeDoTheosForApp:[appManager appWithDisplayName:selectedApp.displayName]];
}

- (IBAction)editTweakButtonClicked:(id)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[selectedApp tweakPath] withApplication:@"CodeRunner"]) {
        [[NSWorkspace sharedWorkspace] openFile:[selectedApp tweakPath] withApplication:@"Xcode"];
    }
}

- (IBAction)analyzeAppButtonClicked:(id)sender {
    // lifesaver: https://stackoverflow.com/questions/16283652/understanding-dispatch-async?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    selectedClass = nil; // This is because I need to clear the methods table view after a new app selected
    selectedApp = [appManager
                   appWithDisplayName:appManager.appList[appsTableView.selectedRow].displayName];
    /* this line below is used for interdevice communication between macOS and iOS so that cycript can launch with the executableName for the -p argument */
    [selectedApp.executableName writeToFile:[NSString stringWithFormat:@"%@/selectedApp.txt",
                                             [fileManager mainDirectoryPath]]
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    [alert setMessageText:@"Before preceding..."];
    [alert setInformativeText:[NSString stringWithFormat:@"Please open %@ on your iOS device", selectedApp.displayName]];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert runModalSheet];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [classesTableView reloadData];
        [methodsTableView reloadData];
    });
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSLog(@"selectedApp = %@", [selectedApp displayName]);
        /* check to see if we have decrypted file or headers */

        if (![fileManager fileExistsAtPath:[fileManager pathOfDecryptedBinaryForApp:selectedApp]] &&
            ![fileManager fileExistsAtPath:[fileManager pathOfHeaderForApp:selectedApp]]) {
            NSLog(@"AM::App has not been decrypted and/or downloaded. Decrypting and downloading now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Decrypting app"];
                [analyzeAppProgressLabel display];
            });

            [self decryptAppAndDownload:selectedApp];
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
    NSString *command = @"printf \"Y\" | apt-get remove com.amiosreverser.amiosreverser-temp-tweak";
    [connectionHandler.session.channel execute:command error:&error];
}

- (IBAction)createTweakButtonClicked:(id)sender {
    [createTweakProgressBar setUsesThreadedAnimation:YES];
    [createTweakProgressBar startAnimation:nil];

    
    [tweakBuilder createTheosProjectForApp:[appManager appWithDisplayName:selectedApp.displayName]];
    
    NSMutableString *tweakCode = [[NSMutableString alloc] init];
    
    [tweakCode appendString:@"NSArray *paths;\
    \nNSString *documentsDirectory;\
    \nNSString *documentTXTPath;\
    \n%ctor {\
    \n\tpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);\
    \n\tdocumentsDirectory = [paths objectAtIndex:0];\
    \n\tdocumentTXTPath = [documentsDirectory stringByAppendingPathComponent:@\"AMLog.txt\"];\
    \n\t[[NSFileManager defaultManager] createFileAtPath:documentTXTPath contents:nil attributes:nil];\
    \n}"];
    
    
    [tweakCode appendString: @"\n\nvoid AMLog(NSString *str) {\
        \n\tstr = [NSString stringWithFormat:@\"%@\\n\\n\", str];\
        \n\tNSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];\
        \n\t[myHandle seekToEndOfFile];\
        \n\t[myHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];\
    \n}"];
    [tweakCode appendString:@"\n\ntypedef id CDUnknownBlockType;\n"];
    [tweakCode appendFormat:@"\n%%hook %@", selectedClass.className];
    
    [methodsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = selectedClass.methodsList[index];
        [tweakCode appendString:[tweakBuilder formatMethodForTweak:objcMethod]];
        
    }];

    [tweakCode appendString:@"\n%end"];
    
    NSLog(@"%@", tweakCode);
    
    /*
     EXAMPLE HOOK FORMAT
     id returnedObj = %orig;
     NSString *log = [NSString stringWithFormat:@"(%@)[initWithCoder:%@]", returnedObj, arg1];
     AMLog(log);
     return returnedObj;
    */
    
//    NSLog(@"selectedApp.tweakPath = %@", selectedApp.tweakPath);
    NSError *error = nil;
    [tweakCode writeToFile:selectedApp.tweakPath
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:&error];
    if (error) {
        NSLog(@"[ERROR] %@", error);
    }

    [createTweakProgressBar stopAnimation:nil];
}

- (void)methodsTableViewClicked:(id)sender {
    methodsTableView.selectedCell.backgroundStyle = NSBackgroundStyleDark;
}


- (void)tableViewClicked:(id)sender {
    /* TODO: Allow a user to select multiple cells by just clicking on them normally
     and a cell's background color will change if selected */
    NSTableView *tableView = sender;
    if (tableView == classesTableView) {
        selectedClass = [selectedApp classWithName:selectedApp.classList[tableView.clickedRow].className];
        [methodsTableView reloadData];
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

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

/* TODO: Move these last two methods into their own class, doesnt belong in a viewcontroller */
/* TODO: Remove parameter for function and just use connectionHandler.session.channel instead!! */
- (NSArray *)getUserAppsForSession:(NMSSHSession *)session {
    //    this will only work for iOS 10, need to update command for other iOSs
    //    make sure to have glib installed via Cydia
    //    find /var/containers/Bundle/Application/* -iname *.app
    
    // MAKE SURE DolosoftTools IS ON DEVICE!!!!!
    NSError *error = nil;
    NSString *response = [session.channel execute:@"DolosoftTools/userapps.sh" error:&error];
    NSLog(@"repsonse: %@" , response);
    NSArray *lines = [response componentsSeparatedByString: @"\n"];
    
    NSMutableArray *apps = [[NSMutableArray alloc] init];
    
    for (int i = 0; i+4 < [lines count]; i+=5) {
        AMApp *app = [[AMApp alloc] initWithDisplayName:lines[i]
                                         executableName:lines[i+1]
                                       bundleIdentifier:lines[i+2]
                                              pathToDir:lines[i+3]
                                       pathToExecutable:lines[i+4]];
        
        if ([app.displayName isEqualToString:@"(null)"]) {
            app.displayName = app.executableName;
        }
        [apps addObject:app];
    }
    
    NSArray *sortedArray;
    sortedArray = [apps sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AMApp *)a displayName];
        NSString *second = [(AMApp *)b displayName];
        return [first compare:second];
    }];
    NSLog(@"Got user's apps' info");
    return sortedArray;
}

- (void)decryptAppAndDownload:(AMApp *)app {
    /*
    // I had this code running for iOS 10 devices
    NSString *decryptCommand = [NSString stringWithFormat:
                                @"cd /var/root/DolosoftDecrypted; \
                                DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib \"%@\"", app.pathToExecutable];
    
    NSError *error = nil;
    [connectionHandler.session.channel execute:decryptCommand error:&error];
    
    // Here we download the decrypted binary to our machine
    NSString *dest = [NSString stringWithFormat:@"%@/%@.decrypted",
                      fileManager.decryptedBinariesDirectoryPath,app.displayName];
    NSString *source = [NSString stringWithFormat:@"/var/root/DolosoftDecrypted/%@.decrypted",app.executableName];
    NSLog(@"source: %@", source);
    NSLog(@"dest: %@", dest);
    [connectionHandler.session.channel downloadFile:source
                                                 to:dest];
     */
    
    /* for iOS 12 */
    NSString *command = [NSString stringWithFormat:@"./dump.py %@", app.bundleIdentifier];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.fridaDirectoryPath];
    [task setArguments:@[ @"-c", command ]];
    [task launch];

    // This waits for the task to finish before returning
    // We need to make sure the .ipa is zipped up before proceeding
    // The NSTask will complete before the file is fully outputted
    while ([task isRunning]) {}
    [NSThread sleepForTimeInterval:4.0f];
    
    command = [NSString stringWithFormat:@"mv \"%@/%@.ipa\" \"%@\"; unzip %@.ipa; mv Payload/*.app/%@ .; rm -r Payload; rm %@.ipa",
                         fileManager.fridaDirectoryPath,
                         app.displayName,
                         fileManager.decryptedBinariesDirectoryPath,
                         app.displayName,
                         app.executableName,
                         app.displayName];
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.decryptedBinariesDirectoryPath];
    [task setArguments:@[ @"-c", command ]];
    [task launch];
    
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
}

- (void)addUserAppsDocumentsDirectory {
    NSError *error = nil;
    NSString *response = [connectionHandler.session.channel execute:@"DolosoftTools/userappsextended.sh" error:&error];
    NSArray *lines = [response componentsSeparatedByString: @"\n"];
    
    for (int i = 0; i+1 < [lines count]; i+=2) {
        NSString *documentDir = lines[i];
        //        NSLog(@"documentDir = %@", documentDir);
        NSString *bundleIdentifier = lines[i+1];
        //        NSLog(@"bundleIdentifier = %@", bundleIdentifier);
        AMApp *app = [appManager appWithBundleIdentifier:bundleIdentifier];
        //        NSLog(@"app = %@", app);
        if (app) {
            app.pathToAppStorageDir = documentDir;
        }
    }
}
@end
