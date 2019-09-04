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
*/
// https://medium.com/@airejie/setting-up-xcode-for-c-projects-17531c3c3941
// for getting libimobiledevice to import
// add the search paths for headers and libs

@implementation AMMainViewController
// NSAlert+SynchronousSheet.h (in case i need this later)
// https://stackoverflow.com/questions/54083843/how-can-i-get-the-ecid-of-a-connected-device-using-libimobiledevice
- (void)viewDidLoad {
//    self.view.window = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
//    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    [super viewDidLoad];
    [connectedToLabel setStringValue:[NSString stringWithFormat:@"Connected to %@ on iOS %@",
                                      _manager.device.DeviceName,
                                      _manager.device.ProductVersion]];
    [self tempMethodName];
    
    if (TEST_MODE) {
        _manager.selectedApp = [_manager.appManager appWithDisplayName:@"Chrome"];
        [self analyzeApp];
    }
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
- (IBAction)selectAppButtonClicked:(id)sender {
    _manager.appsViewController.manager = _manager;
    [self presentViewControllerAsSheet:_manager.appsViewController];
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
    NSString *command = [NSString stringWithFormat:@"killall -9 \"%@\"", _manager.selectedApp.executableName];
    [_manager.connectionHandler.session.channel execute:command error:&error];
}
- (IBAction)stringsButtonClicked:(id)sender {
    NSError *error;
    [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/bin/bash"]
                                arguments:@[ @"-c", [NSString stringWithFormat:@"strings \"%@\" > %@", [_manager.fileManager pathOfDecryptedBinaryForApp:_manager.selectedApp], _manager.fileManager.stringsOutputPath] ]
                                    error:&error
                       terminationHandler:^(NSTask *t){}];
    _manager.stringsViewController.strings = [[NSString stringWithContentsOfFile:_manager.fileManager.stringsOutputPath
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:nil] componentsSeparatedByString:@"\n"];
    [self presentViewControllerAsSheet:_manager.stringsViewController];
}
- (IBAction)clearAppCacheButtonClicked:(id)sender {
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Caches", _manager.selectedApp.pathToAppStorageDir];
    NSString *command = [NSString stringWithFormat:@"rm -r %@", cachePath];
    [_manager.connectionHandler.session.channel execute:command error:nil];
    NSLog(@"Cleared %@'s cache", _manager.selectedApp.displayName);
}

- (IBAction)clearLogButtonClicked:(id)sender {
    [logTextView setString:@""];
    [_manager.logger removeLogForApp:_manager.selectedApp];
}

- (void)getAppLog {
    NSString *logPath = [NSString stringWithFormat:@"%@/AMLog.txt", [_manager.fileManager mainDirectoryPath]];
    [_manager.fileManager removeItemAtPath:logPath error:nil];
    [logTextView setString:[_manager.logger retrieveLogForApp:_manager.selectedApp]];
}

- (IBAction)getLogButtonClicked:(id)sender {
    /* TODO: Make the log live update */
    //    NSTimer *timer;
    //    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
    //                                             target:self selector:@selector(getAppLog) userInfo:nil repeats:YES];
    [self getAppLog];
}

- (IBAction)installTweakButtonClicked:(id)sender {
    if ([_manager.fileManager fileExistsAtPath:_manager.selectedApp.tweakDirPath isDirectory:nil]) {
        [_manager.tweakBuilder makeDoTheosForApp:[_manager.appManager appWithDisplayName:_manager.selectedApp.displayName]];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"No tweak to install. You must create a tweak before installing."];
        [alert runModal];
    }
}
- (IBAction)openHeaderFileButtonClicked:(id)sender {
    NSString *pathToSelectedClassHeader = [NSString stringWithFormat:@"%@/%@.h", _manager.selectedApp.headerPath, _manager.selectedClass];
    if (![[NSWorkspace sharedWorkspace] openFile:pathToSelectedClassHeader]) {
        [[NSWorkspace sharedWorkspace] openFile:pathToSelectedClassHeader withApplication:@"Xcode"];
    }
}

- (IBAction)editTweakButtonClicked:(id)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[_manager.selectedApp tweakFilePath]]) {
        [[NSWorkspace sharedWorkspace] openFile:[_manager.selectedApp tweakFilePath] withApplication:@"Xcode"];
    }
}

- (void)analyzeApp {
    // lifesaver: https://stackoverflow.com/questions/16283652/understanding-dispatch-async?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    
    NSLog(@"_manager.selectedApp = %@", [_manager.selectedApp displayName]);
    
    /* this line below is used for interdevice communication between macOS and iOS so that cycript can launch with the executableName for the -p argument */
    [_manager.selectedApp.executableName writeToFile:[NSString stringWithFormat:@"%@/selectedApp.txt",
                                                      [_manager.fileManager mainDirectoryPath]]
                                          atomically:YES
                                            encoding:NSUTF8StringEncoding
                                               error:nil];
    
    [classesTableView reloadData];
    [methodsTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        /* check to see if we have decrypted file */
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfDecryptedBinaryForApp:_manager.selectedApp]]) {
            NSLog(@"AM::App has not been decrypted and/or downloaded. Decrypting and downloading now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Decrypting app"];
                [analyzeAppProgressLabel display];
            });
            [_manager.deviceManager decryptAppAndDownload:_manager.selectedApp];
        }
        
        /* check to see if we have headers */
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfHeaderForApp:
                                                     _manager.selectedApp]]) {
            NSLog(@"headerPath = %@", _manager.selectedApp.headerPath);
            NSLog(@"AM::Headers have not been dumped. Dumping now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Dumping headers"];
                [analyzeAppProgressLabel display];
            });
            [_manager.appManager dumpHeadersForApp:_manager.selectedApp];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [analyzeAppProgressLabel setStringValue:@"Parsing Objective-C data from headers"];
            [analyzeAppProgressLabel display];
        });
        
        [_manager.appManager initializeClassListForApp:_manager.selectedApp];
        
        if ([_manager.selectedApp.classList count] != 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Analysis finished"];
                [classesTableView reloadData];
                [methodsTableView reloadData];
                if (TEST_MODE) {
                    _manager.selectedClass = [_manager.selectedApp classWithName:@"JsPasswordManager"];
                    [methodsTableView reloadData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Analysis failed"];
                [_targetAppLabel setStringValue:@"Target app: (null)"];
                _manager.selectedApp = nil;
                [classesTableView reloadData];
                [methodsTableView reloadData];
                NSLog(@"Failed to analyze %@, make sure the app is open and in the foreground on your iOS device. Only apps installed via the App Store are supported as of now", _manager.selectedApp);
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Dismiss"];
                [alert setMessageText:@"Error"];
                [alert setInformativeText:[NSString stringWithFormat:@"Failed to analyze %@, make sure the app is open and in the foreground on your iOS device. Only apps installed via the App Store are supported as of now", _manager.selectedApp.displayName]];
                [alert runModal];
            });
        }
        
    });
    
}

- (IBAction)removeTweakButtonClicked:(id)sender {
    NSError *error = nil;
    /* this command works but it requires root. I am leaving this here in case I revert to using root
       but the new solution does not require root so it is preferred */
//    NSString *command = [NSString stringWithFormat:@"printf \"Y\" | apt-get remove com.dolosoft.dolosoft-%@",
//                         _manager.selectedApp.displayNameLowercaseNoSpace];
//    [_manager.connectionHandler.session.channel execute:command error:&error];
    
    NSString *command = [NSString stringWithFormat:@"removetweak com.dolosoft.dolosoft-%@",
                         _manager.selectedApp.displayNameLowercaseNoSpace];
    [_manager.connectionHandler.session.channel execute:command error:&error];
}

- (IBAction)createTweakButtonClicked:(id)sender {
    [createTweakProgressBar setUsesThreadedAnimation:YES];
    [createTweakProgressBar startAnimation:nil];
    
    // Collect all the methods to we want
    NSMutableArray<AMObjcMethod *> *methods = [[NSMutableArray alloc] init];
    [methodsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = _manager.selectedClass.methodsList[index];
        [methods addObject:objcMethod];
    }];
    
    [_manager.tweakBuilder createTheosProjectForApp:_manager.selectedApp];
    [_manager.tweakBuilder writeTweakCodeForApp:_manager.selectedApp forObjcClass:_manager.selectedClass withMethods:methods];
    
    [createTweakProgressBar stopAnimation:nil];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    if (tableView.selectedRow != -1) {
        if (tableView == classesTableView) {
            _manager.selectedClass = [_manager.selectedApp classWithName:_manager.selectedApp.classList[tableView.selectedRow].className];
            [methodsTableView reloadData];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == classesTableView) {
        return [_manager.selectedApp.classList count];
    } else if (tableView == methodsTableView) {
        return [_manager.selectedClass.methodsList count];
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

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"methods"]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"methodCell" owner:self];
        cell.textField.stringValue = _manager.selectedClass.methodsList[row].callSyntax;
        return cell;
    } else {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"classCell" owner:self];
        cell.textField.stringValue = _manager.selectedApp.classList[row].className;
        return cell;
    }
    return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"classes"]) {
        return _manager.selectedApp.classList[row].className;
    } else if ([identifier isEqualToString:@"methods"]) {
        [methodsTableView sizeToFit];
        return _manager.selectedClass.methodsList[row].callSyntax;
    } else {
        return @"THIS SHOULD NEVER RETURN";
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
@end
