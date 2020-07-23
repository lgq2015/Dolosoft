//
//  AMManager.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/9/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//
#include <stdlib.h>
#import "AMManager.h"
#import "AMR_ANSIEscapeHelper.h"
// TODO: rewrite class dump parser to mimic Flex's
@implementation AMManager
- (instancetype)init {
    self = [super init];
    [self loadPreferences];
    _fileManager = [[AMFileManager alloc] init];
    if (![_fileManager libimobiledeviceInstalled]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Dismiss"];
        [alert setMessageText:@"Missing library"];
        [alert setInformativeText:[NSString stringWithFormat:@"Error: %@\nI HIGHLY recommend installing libimobiledevice on your Mac! Try \"brew install libimobiledevice\". You should be able to run \"ideviceinfo\" with your iOS device plugged in and it should bring up device information. If you get an error, run the code here https://pastebin.com/PHNexvwM inside your terminal. After installing libimobiledevice, quit Dolosoft and try again.", @"some error message"]];
        [alert runModal];
        [NSApp terminate:nil];
    }
    _hookedMethods = [[NSMutableArray alloc] init];
    group = dispatch_group_create();
    background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _device = [[AMDevice alloc] init];
    // https://stackoverflow.com/questions/26689699/initializing-another-window-using-storyboard-for-os-x
    storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    _initialViewController = [storyBoard instantiateControllerWithIdentifier:@"InitialViewController"];
    _deviceInfoViewController = [storyBoard instantiateControllerWithIdentifier:@"DeviceInfoViewController"];
    _stringsViewController = [storyBoard instantiateControllerWithIdentifier:@"StringsViewController"];
    _appsViewController = [storyBoard instantiateControllerWithIdentifier:@"AppsViewController"];
     _windowController = [[WindowController alloc] initWithWindow:
                          [NSWindow windowWithContentViewController:_initialViewController]];
    [self performSelectorInBackground:@selector(checkForDevice) withObject:self];
    [_windowController showWindow:self];
    return self;
}

- (void)loadPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *themeMode = [defaults objectForKey:@"themeMode"];
    if ([themeMode isEqualToString:@"Light"]) {
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    } else if ([themeMode isEqualToString:@"Dark"]) {
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }
}

- (void)redirectOutput {
    /*
    // https://stackoverflow.com/questions/16391279/how-to-redirect-stdout-to-a-nstextview
    // https://stackoverflow.com/questions/29548811/real-time-nstask-output-to-nstextview-with-swift
    // I may use the second link later to make the console similar to how it is in Xcode
    _consolePipe = [NSPipe pipe];
    dup2([[_consolePipe fileHandleForWriting] fileDescriptor], fileno(stderr));
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                                      _consolePipe.fileHandleForReading.fileDescriptor,
                                                      0,
                                                      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    __weak typeof(self) weakSelf = self;
    _consolePipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle *handle) {
//        AMR_ANSIEscapeHelper *ansiEscapeHelper = [[AMR_ANSIEscapeHelper alloc] init];
        void* data = malloc(4096);
        ssize_t readResult = 0;
        do {
            errno = 0;
            readResult = read(_consolePipe.fileHandleForReading.fileDescriptor, data, 256);
        } while (readResult == -1 && errno == EINTR);

        if (readResult > 0) {
            NSString* stdOutString = [[NSString alloc] initWithBytesNoCopy:data length:readResult encoding:NSUTF8StringEncoding freeWhenDone:YES];
//            printf("string = %s\n", [stdOutString cString]);
            for (int i = 0; i < [stdOutString length]; i++) {
//                char a = [stdOutString cString][i];
//                printf("char @ %c = %d\n", a, a);
            }

                        NSAttributedString* stdOutAttributedString = [[NSAttributedString alloc]
                                                                      initWithString:stdOutString
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName : [NSColor whiteColor],
                                                                                   NSFontAttributeName : [NSFont fontWithName:@"Monaco" size:12]
                                                                    }];

            dispatch_sync(dispatch_get_main_queue(), ^(void){
                if (weakSelf.mainViewController) {
                    [weakSelf.mainViewController.consoleTextView.textStorage appendAttributedString:stdOutAttributedString];
                    [weakSelf.mainViewController.consoleTextView scrollToEndOfDocument:nil];
                }
            });
        } else {
            free(data);
        }
    };
    dispatch_resume(source);
    */
}

- (void)checkForDevice {
    while (!_device && !TEST_MODE) {
        @try {
            _device = [[AMDevice alloc] init];
        } @catch (NSException *exception) {
            if (!_device) {
                NSLog(@"[Exception caught] %@", exception.reason);
                if ([exception.reason isEqualToString:@"ERROR: Could not connect to lockdownd, error code -5"]) {
                    [self checkForDevice]; // sometimes have to repeat this is code is -5, idk why
                }
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.initialViewController setStatus:[NSString stringWithFormat:@"%@\n%@", @"Waiting for device...", exception.reason]];
                });
            }
        }
    }
    [self deviceDidAttach];
    [self start];
}

- (void)deviceDidAttach {
    // https://stackoverflow.com/questions/10034045/ui-does-not-update-when-main-thread-is-blocked-in-cocoa-app
    NSLog(@"deviceDidAttach");
    [_initialViewController deviceDidAttachWithName:_device.DeviceName];
}

- (void)dismissVC:(NSViewController *)viewController {
    [viewController dismissViewController:viewController];
}

- (void)presentVCAsModal:(NSViewController *)viewController {
    [viewController presentViewControllerAsModalWindow:viewController];
}

- (void)start {
    [self setup];
    /* dispatch_group_notify makes the following code wait for the setup to finish */
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        _mainViewController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"];
        _mainViewController.manager = self; // TODO: I hate the way this is structured, so restructure
        [_windowController close];
        _windowController = [[WindowController alloc] initWithWindow:
                             [NSWindow windowWithContentViewController:_mainViewController]];
        [_windowController showWindow:self];
        [self redirectOutput];
    });
}

- (void)setup {
    /* leaving these here in case I need to reset the defaults */
//    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    dispatch_group_async(group, background_queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Attempting to connect to device via SSH"];
        });
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        static NSString *mobileUserPassword;
        mobileUserPassword = [defaults objectForKey:@"mobileUserPassword"];

        if (!mobileUserPassword && !TEST_MODE) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Prompting for mobile mobileUserPassword"];
            });
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                mobileUserPassword = [AMManager getSecureUserInput:@"Enter iOS device mobile password"];
            });
            [defaults setObject:mobileUserPassword forKey:@"mobileUserPassword"];
            [defaults synchronize];
        }

        _appManager = [[AMAppManager alloc] initWithFileManager:_fileManager];
        _tweakBuilder = [[AMTweakBuilder alloc] initWithFileManager:_fileManager];
        _tweakBuilder.manager = self;
        _logger = [[AMLogger alloc] initWithFileManager:_fileManager];
        
        // TODO: Give user the option to connect via localhost or private ip address
        NSString *hostName = @"localhost";
        NSString *username = @"mobile";
        NSInteger port = 2222;

        _connectionHandler = [[AMConnectionHandler alloc]
                              initWithHost:hostName
                              port:port
                              username:username
                              password:mobileUserPassword];

        // if test mode than skip connection bc dont have device
        if (!TEST_MODE) {
            while (!_connectionHandler.session.isConnected) { // we keep trying until we get the right mobileUserPassword
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    [_initialViewController setStatus:@"Prompting for mobile password"];
                });
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    mobileUserPassword = [AMManager getSecureUserInput:@"Incorrect iOS device mobile password. Please try again"];
                });
                [defaults setObject:mobileUserPassword forKey:@"mobileUserPassword"];
                [defaults synchronize];
                _connectionHandler = [[AMConnectionHandler alloc] initWithHost:hostName
                                                                          port:port
                                                                      username:username
                                                                      password:mobileUserPassword];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Preparing device"];
        });

        _deviceManager = [[AMDeviceManager alloc] initWithConnectionHandler:_connectionHandler fileManager:_fileManager];
        _deviceManager.manager = self;

        if (TEST_MODE) {
            _appManager.appList = [_deviceManager getUserApps];
            return;
        }
        
        _logger.connectionHandler = _connectionHandler;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Checking if Dolosoft tools are installed on iOS device"];
        });
        if (!TEST_MODE) {
            if (![self toolInstalled:@"installedapps"]) {
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"Quit"];
                    [alert setMessageText:@"Missing tool on iOS device"];
                    [alert setInformativeText:@"installedapps is not installed on the iOS device. Add my repository https://andermoran.github.io/repo and then install installedapps"];
                    [alert runModal];
                });
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [NSApp terminate:nil];
                });
            }
            
            if (![self toolInstalled:@"removetweak"]) {
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"Quit"];
                    [alert setMessageText:@"Missing tool on iOS device"];
                    [alert setInformativeText:@"removetweak is not installed on the iOS device. Add my repository https://andermoran.github.io/repo and then install removetweak"];
                    [alert runModal];
                });
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [NSApp terminate:nil];
                });
            }
            
            if (![self toolInstalled:@"flexdecrypt"]) {
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"Quit"];
                    [alert setMessageText:@"Missing tool on iOS device"];
                    [alert setInformativeText:@"flexdecrypt is not installed on the iOS device. Learn how to install flexdecrypt on your iOS device at https://github.com/JohnCoates/flexdecrypt"];
                    [alert runModal];
                });
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [NSApp terminate:nil];
                });
            }
            
            /*
            if (![self toolInstalled:@"frida-server"]) {
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"Quit"];
                    [alert setMessageText:@"Missing tool on iOS device"];
                    [alert setInformativeText:@"frida-server is not installed on the iOS device. Learn how to install Frida on your iOS device at https://frida.re/docs/ios/#with-jailbreak"];
                    [alert runModal];
                });
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [NSApp terminate:nil];
                });
            }
             */

            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Getting list of installed apps"];
            });
            _appManager.appList = [_deviceManager getUserApps];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Setup complete"];
            });
        } else {
            NSLog(@"Unable to establish connection with iOS device");
        }
    });
}

- (BOOL)toolInstalled:(NSString *)toolName {
    NSString *command = [NSString stringWithFormat:@"if test -f /usr/bin/%@ -o -f /usr/sbin/%@; then printf '%@ is installed'; fi", toolName, toolName, toolName];
    NSString *response = [_connectionHandler.session.channel execute:command error:nil];
    if (![response isEqualToString:[NSString stringWithFormat:@"%@ is installed", toolName]]) {
        return NO;
    }
    return YES;
}

+ (NSString *)getSecureUserInput:(NSString *)prompt {
    // https://stackoverflow.com/questions/7387341/how-to-create-and-get-return-value-from-cocoa-dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:prompt];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Quit"];
    
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        return [input stringValue];
    } else {
        [NSApp terminate:nil];
        return nil;
    }
}
@end
