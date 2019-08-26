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
// NSAlert+SynchronousSheet.h (in case i need this later)
// https://stackoverflow.com/questions/54083843/how-can-i-get-the-ecid-of-a-connected-device-using-libimobiledevice
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.backgroundColor = [NSColor colorWithCalibratedRed:71.0f/255.0f
                                                                green:69.0f/255.0f
                                                                 blue:68.0f/255.0f
                                                                alpha:1].CGColor;

    [appsTableView setAction:@selector(tableViewClicked:)];
    [classesTableView setAction:@selector(tableViewClicked:)];
    [methodsTableView setAction:@selector(tableViewClicked:)];

//    terminalTextView.editable = NO;
    terminalTextView.font = [NSFont fontWithName:@"Monaco" size:12];

    logTextView.editable = NO;
    logTextView.font = [NSFont fontWithName:@"Monaco" size:12];
    
    [connectedToLabel setStringValue:[NSString stringWithFormat:@"Connected to %@ on iOS %@",
                                      _manager.device.DeviceName,
                                      _manager.device.ProductVersion]];
    [self tempMethodName];
}
// I WAS WORKING ON FIXING THE TERMINAL UPDATES
- (void)tempMethodName {
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tempMethodName) userInfo:nil repeats:YES];
}

- (void)tempMethodName1 {
    // NSLog(@"In the loop!");
    NSString *logPath = [NSString stringWithFormat:@"%@/liveTerminalLog.txt", [_manager.fileManager mainDirectoryPath]];
    NSString* content = [NSString stringWithContentsOfFile:logPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [terminalTextView setString:content];
    });
}

- (IBAction)deviceInfoButtonClicked:(id)sender {
    _manager.deviceInfoViewController.deviceInfo = _manager.device.deviceInfo;
    [self presentViewControllerAsSheet:_manager.deviceInfoViewController];
}

- (IBAction)cycriptButtonClicked:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Cycript functionality disabled"];
    [alert setInformativeText:@"On the iOS 10.1 yalu mach_portal jailbreak, I had this code working but since cycript does not work on iOS 12, the functionality has been disabled. I may get this code working for iOS 11 jailbreaks but it is a lot trickier."];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
    
    /* I had this code working on iOS 10.1 yalu mach_portal jb.
       Keeping it here in case cycript is ever revived */
//    NSString *loadCycriptPath = [NSString stringWithFormat:@"%@/loadCycript.sh", [_manager.fileManager mainDirectoryPath]];
//    [[NSWorkspace sharedWorkspace] openFile:loadCycriptPath withApplication:@"Terminal"];
}
- (IBAction)SSHSessionButtonClicked:(id)sender {
    NSBundle *main = [NSBundle mainBundle];
    NSString *loadSSHPath = [main pathForResource:@"loadSSH" ofType:@"sh"];
    [[NSWorkspace sharedWorkspace] openFile:loadSSHPath withApplication:@"Terminal"];
}

- (IBAction)respringButtonClicked:(id)sender {
    NSError *error = nil;
    [_manager.connectionHandler.session.channel execute:@"killall -9 SpringBoard" error:&error];
}
- (IBAction)killAppButtonClicked:(id)sender {
    NSError *error = nil;
    NSString *command = [NSString stringWithFormat:@"killall -9 \"%@\"", selectedApp.executableName];
    [_manager.connectionHandler.session.channel execute:command error:&error];
}
- (IBAction)stringsButtonClicked:(id)sender {
    NSError *error;
    [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/bin/bash"]
                                arguments:@[ @"-c", [NSString stringWithFormat:@"strings \"%@\" > %@", [_manager.fileManager pathOfDecryptedBinaryForApp:selectedApp], _manager.fileManager.stringsOutputPath] ]
                                    error:&error
                       terminationHandler:^(NSTask *t){}];
    _manager.stringsViewController.strings = [[NSString stringWithContentsOfFile:_manager.fileManager.stringsOutputPath
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:nil] componentsSeparatedByString:@"\n"];
    [self presentViewControllerAsSheet:_manager.stringsViewController];
}
- (IBAction)clearAppCacheButtonClicked:(id)sender {
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Caches", selectedApp.pathToAppStorageDir];
    NSString *command = [NSString stringWithFormat:@"rm -r %@", cachePath];
    [_manager.connectionHandler.session.channel execute:command error:nil];
    NSLog(@"Cleared %@'s cache", selectedApp.displayName);
}

- (IBAction)clearLogButtonClicked:(id)sender {
    [logTextView setString:@""];
    [_manager.logger removeLogForApp:selectedApp];
}

- (void)getAppLog {
    NSString *logPath = [NSString stringWithFormat:@"%@/AMLog.txt", [_manager.fileManager mainDirectoryPath]];
    [_manager.fileManager removeItemAtPath:logPath error:nil];
    [logTextView setString:[_manager.logger retrieveLogForApp:selectedApp]];
}

- (IBAction)getLogButtonClicked:(id)sender {
    /* TODO: Make the log live update */
    //    NSTimer *timer;
    //    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
    //                                             target:self selector:@selector(getAppLog) userInfo:nil repeats:YES];
    [self getAppLog];
}

- (IBAction)installTweakButtonClicked:(id)sender {
    if ([_manager.fileManager fileExistsAtPath:selectedApp.tweakDirPath isDirectory:nil]) {
        [_manager.tweakBuilder makeDoTheosForApp:[_manager.appManager appWithDisplayName:selectedApp.displayName]];
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
    NSLog(@"selectedApp = %@", [selectedApp displayName]);
    
    /* this line below is used for interdevice communication between macOS and iOS so that cycript can launch with the executableName for the -p argument */
    [selectedApp.executableName writeToFile:[NSString stringWithFormat:@"%@/selectedApp.txt",
                                             [_manager.fileManager mainDirectoryPath]]
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:nil];
    
    [classesTableView reloadData];
    [methodsTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        /* check to see if we have decrypted file or headers */
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfDecryptedBinaryForApp:selectedApp]] &&
            ![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfHeaderForApp:selectedApp]]) {
            NSLog(@"AM::App has not been decrypted and/or downloaded. Decrypting and downloading now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Decrypting app"];
                [analyzeAppProgressLabel display];
            });
            [_manager.deviceManager decryptAppAndDownload:selectedApp];
        }
        
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfHeaderForApp:
                                            selectedApp]]) {
            NSLog(@"headerPath = %@", selectedApp.headerPath);
            NSLog(@"AM::Headers have not been dumped. Dumping now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Dumping headers"];
                [analyzeAppProgressLabel display];
            });
            [_manager.appManager dumpHeadersForApp:selectedApp];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [analyzeAppProgressLabel setStringValue:@"Parsing headers"];
            [analyzeAppProgressLabel display];
        });
        
        //NSLog(@"LABEL = %@", [analyzeAppProgressLabel di]);
        [_manager.appManager initializeClassListForApp:selectedApp];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [analyzeAppProgressLabel setStringValue:@"Analysis finished"];
            [classesTableView reloadData];
            [methodsTableView reloadData];
        });
        
    });
    
}

- (IBAction)removeTweakButtonClicked:(id)sender {
    NSError *error = nil;
    /* this command works but it requires root. I am leaving this here in case I revert to using root
       but the new solution does not require root so it is preferred */
//    NSString *command = [NSString stringWithFormat:@"printf \"Y\" | apt-get remove com.dolosoft.dolosoft-%@",
//                         selectedApp.displayNameLowercaseNoSpace];
//    [_manager.connectionHandler.session.channel execute:command error:&error];
    
    NSString *command = [NSString stringWithFormat:@"removetweak com.dolosoft.dolosoft-%@",
                         selectedApp.displayNameLowercaseNoSpace];
    [_manager.connectionHandler.session.channel execute:command error:&error];
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
    
    [_manager.tweakBuilder createTheosProjectForApp:selectedApp];
    [_manager.tweakBuilder writeTweakCodeForApp:selectedApp forObjcClass:selectedClass withMethods:methods];
    
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
            selectedApp = [_manager.appManager appWithDisplayName:_manager.appManager.appList[appsTableView.selectedRow].displayName];
            [targetAppLabel setStringValue:[NSString stringWithFormat:@"Target app: %@", selectedApp.displayName]];
            selectedClass = nil;
            [classesTableView reloadData];
            [methodsTableView reloadData];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == appsTableView) {
        return [_manager.appManager.appList count];
    } else if (tableView == classesTableView) {
        return [selectedApp.classList count];
    } else if (tableView == methodsTableView) {
        return [selectedClass.methodsList count];
    } else {
        return 0;
    }
}

// TODO: Color code the methods! It's hard to search
/* removing this for now as it is causing issues with the methodsTableView and classesTableView */
//- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    NSString *identifier = [tableColumn identifier];
//    if ([identifier isEqualToString:@"apps"]) {
//        AMApp *app = [_manager.appManager.appList objectAtIndex:row];
//        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"appNameCell" owner:self];
//        cell.textField.stringValue = app.displayName;
//        cell.imageView.image = app.icon;
//        cell.imageView.wantsLayer = YES;
//        cell.imageView.canDrawSubviewsIntoLayer = YES;
//        cell.imageView.layer.cornerRadius = 5;
//        cell.imageView.layer.masksToBounds = YES;
//
//        [cell.textField setFont:[NSFont fontWithName:@"ArialMT" size:5]];
//        if (!cell.imageView.image) {
//            cell.imageView.image = [[NSImage alloc] initWithContentsOfFile:@"/Users/moranander00/Library/Application Support/Dolosoft/icon_default.png"];
//        }
//        return cell;
//    }
//    return nil;
//}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"apps"]) {
        AMApp *app = [_manager.appManager.appList objectAtIndex:row];
        return app.displayName;
    } else if ([identifier isEqualToString:@"classes"]) {
        return selectedApp.classList[row].className;
    } else if ([identifier isEqualToString:@"methods"]) {
        return selectedClass.methodsList[row].callSyntax;
    } else {
        return @"THIS SHOULD NEVER RETURN";
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
@end
