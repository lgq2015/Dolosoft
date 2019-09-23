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
- (void)viewDidLoad {
    [super viewDidLoad];
    methodsTableView.doubleAction = @selector(hookMethodsButtonClicked:);
    NSButtonCell *consoleButtonCell = [consoleButton cell];
    consoleButtonCell.backgroundColor = [NSColor controlBackgroundColor];
    [connectedToLabel setStringValue:[NSString stringWithFormat:@"Connected to %@ on iOS %@",
                                      _manager.device.DeviceName,
                                      _manager.device.ProductVersion]];
    
    if (TEST_MODE) {
        _manager.selectedApp = [_manager.appManager appWithDisplayName:@"Chrome"];
        [self analyzeApp];
    }
}

- (void)keyDown:(NSEvent *)event {
    // https://stackoverflow.com/questions/4668847/nstableview-delete-key
    
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if ((key == NSEnterCharacter || key == NSCarriageReturnCharacter)
        ) {
        [self hookMethodsButtonClicked:nil];
    }
    [super keyDown:event];
}

- (IBAction)removeHookButtonClicked:(id)sender {
     [selectedMethodsTableView.selectedRowIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = _manager.hookedMethods[index];
        [_manager.hookedMethods removeObject:objcMethod];
    }];
    [selectedMethodsTableView reloadData];
    NSLog(@"%@", _manager.hookedMethods);
}

- (IBAction)hookMethodsButtonClicked:(id)sender {
    [methodsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = _manager.selectedClass.methodsList[index];
        if (![_manager.hookedMethods containsObject:objcMethod]) {
            [_manager.hookedMethods addObject:objcMethod];
        }
    }];
    [selectedMethodsTableView reloadData];
    NSLog(@"%@", _manager.hookedMethods);
}

- (IBAction)selectAppButtonClicked:(id)sender {
    _manager.appsViewController.manager = _manager;
    [self presentViewControllerAsSheet:_manager.appsViewController];
}

- (IBAction)deviceInfoButtonClicked:(id)sender {
    if (_manager.device.deviceInfo) {
        _manager.deviceInfoViewController.deviceInfo = _manager.device.deviceInfo;
        [self presentViewControllerAsSheet:_manager.deviceInfoViewController];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Dismiss"];
        [alert setMessageText:@"Alert"];
        [alert setInformativeText:@"Because you do not have libimobiledevice installed, device information is not available. I HIGHLY recommend installing libimobiledevice on your Mac! Try \"brew install libimobiledevice\". You should be able to run \"ideviceinfo\" with your iOS device plugged in and it should bring up device information. If you get an error, run the code here https://pastebin.com/PHNexvwM inside your terminal. After installing libimobiledevice, quit Dolosoft and try again."];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:self.view.window completionHandler:NULL];
//         [alert beginSheetModalForWindow:[self.view window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
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
- (IBAction)iOSApplicationLogButtonClicked:(id)sender {
    NSButtonCell *selectedCell = [iOSApplicationLogButton cell];
    selectedCell.backgroundColor = [NSColor controlBackgroundColor];
    NSButtonCell *deselectedCell = [consoleButton cell];
    deselectedCell.backgroundColor = [NSColor clearColor];
    [iOSApplicationLogButton setState:NSControlStateValueOn];
    [consoleButton setState:NSControlStateValueOff];
    logTextView.enclosingScrollView.hidden = NO;
    _consoleTextView.enclosingScrollView.hidden = YES;
}
- (IBAction)consoleButtonClicked:(id)sender {
    NSButtonCell *selectedCell = [consoleButton cell];
    selectedCell.backgroundColor = [NSColor controlBackgroundColor];
    NSButtonCell *deselectedCell = [iOSApplicationLogButton cell];
    deselectedCell.backgroundColor = [NSColor clearColor];
    [consoleButton setState:NSControlStateValueOn];
    [iOSApplicationLogButton setState:NSControlStateValueOff];
    _consoleTextView.enclosingScrollView.hidden = NO;
    logTextView.enclosingScrollView.hidden = YES;
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
    [self getAppLog];
}

- (IBAction)installTweakButtonClicked:(id)sender {
    if (!_manager.selectedApp) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"No app selected. Please select an app."];
        [alert runModal];
        return;
    }
    
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
    if (!_manager.selectedApp) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"No app selected. Please select an app."];
        [alert runModal];
        return;
    }
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
    [selectedMethodsTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        /* check to see if we have decrypted file */
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfDecryptedBinaryForApp:_manager.selectedApp]]) {
            NSLog(@"App has not been decrypted and/or downloaded. Decrypting and downloading now.");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [analyzeAppProgressLabel setStringValue:@"Decrypting app"];
                [analyzeAppProgressLabel display];
            });
            [_manager.deviceManager decryptAppAndDownload:_manager.selectedApp];
        }
        
        /* check to see if we have headers */
        if (![_manager.fileManager fileExistsAtPath:[_manager.fileManager pathOfHeaderForApp:
                                                     _manager.selectedApp]]) {
//            NSLog(@"headerPath = %@", _manager.selectedApp.headerPath);
            NSLog(@"Headers have not been dumped. Dumping now.");
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
    if (!_manager.selectedApp) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"No app selected. Please select an app."];
        [alert runModal];
        return;
    }
    [createTweakProgressBar setUsesThreadedAnimation:YES];
    [createTweakProgressBar startAnimation:nil];
    
    // Collect all the methods to we want
    NSMutableArray<AMObjcMethod *> *methods = [[NSMutableArray alloc] init];
    [methodsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        AMObjcMethod *objcMethod = _manager.selectedClass.methodsList[index];
        [methods addObject:objcMethod];
    }];
    
    [_manager.tweakBuilder createTheosProjectForApp:_manager.selectedApp];
//    [_manager.tweakBuilder writeTweakCodeForApp:_manager.selectedApp forObjcClass:_manager.selectedClass withMethods:methods];
    
    [_manager.tweakBuilder writeTweakCodeForApp:_manager.selectedApp forMethods:_manager.hookedMethods];
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
    } else if (tableView == selectedMethodsTableView) {
        return [_manager.hookedMethods count];
    } else {
        return 0;
    }
}

// TODO: Color code the methods! It's hard to search
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"methods"]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"methodCell" owner:self];
        cell.textField.stringValue = _manager.selectedClass.methodsList[row].callSyntax;
        return cell;
    } else if ([identifier isEqualToString:@"classes"]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"classCell" owner:self];
        cell.textField.stringValue = _manager.selectedApp.classList[row].className;
        return cell;
    } else if ([identifier isEqualToString:@"selectedMethodsClass"]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"selectedMethodsClassCell" owner:self];
        cell.textField.stringValue = _manager.hookedMethods[row].masterClass.className;
        return cell;
    } else if ([identifier isEqualToString:@"selectedMethodsMethod"]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"selectedMethodsMethodCell" owner:self];
        cell.textField.stringValue = _manager.hookedMethods[row].callSyntax;
        return cell;
    } else {
        NSLog(@"error we should never be here!!!");
        NSTableCellView *cell = [[NSTableCellView alloc] init];
        cell.textField.stringValue = @"error";
        return cell;
    }
    return nil;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
@end
