//
//  AMManager.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/9/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AMManager.h"

@implementation AMManager
- (instancetype)init {
    self = [super init];
    group = dispatch_group_create();
    background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _device = [[AMDevice alloc] init];
    // https://stackoverflow.com/questions/26689699/initializing-another-window-using-storyboard-for-os-x
    storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    _initialViewController = [storyBoard instantiateControllerWithIdentifier:@"InitialViewController"]; // instantiate your window controller
    _deviceInfoViewController = [storyBoard instantiateControllerWithIdentifier:@"DeviceInfoViewController"]; // instantiate your window controller
    _stringsViewController = [storyBoard instantiateControllerWithIdentifier:@"StringsViewController"]; // instantiate your window controller
    [_initialViewController presentViewControllerAsModalWindow:_initialViewController];
    [self performSelectorOnMainThread:@selector(checkForDevice) withObject:nil waitUntilDone:NO];
    return self;
}

- (void)checkForDevice {
    while (!_device) {
        _device = [[AMDevice alloc] init];
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
        _mainViewController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"]; // instantiate your window controller
        _mainViewController.manager = self; // TODO: I hate the way this is structured, so restructure
        [self dismissVC:_initialViewController];
        [self presentVCAsModal:_mainViewController];
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

        _fileManager = [[AMFileManager alloc] init];
        _appManager = [[AMAppManager alloc] initWithFileManager:_fileManager];
        _tweakBuilder = [[AMTweakBuilder alloc] initWithFileManager:_fileManager];
        _logger = [[AMLogger alloc] initWithFileManager:_fileManager];
        
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
                    mobileUserPassword = [AMManager getSecureUserInput:@"Incorrect iOS device mobile mobileUserPassword. Please try again"];
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

        if (TEST_MODE) {
            _appManager.appList = [_deviceManager getUserApps];
            return;
        }
        if (_connectionHandler.session.isConnected) { // TODO: Reformat this as this if statement is redundant
            _logger.connectionHandler = _connectionHandler;

            // should put some check here to see if getinstalledappsinfo is installed on iOS device;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Checking if Dolosoft tools are installed on iOS device"];
            });
            if (!TEST_MODE) {
                if (![self toolInstalled:@"getinstalledappsinfo"]) {
                    dispatch_sync(dispatch_get_main_queue(), ^(void){
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"Quit"];
                        [alert setMessageText:@"Error"];
                        [alert setInformativeText:@"getinstalledappsinfo is not installed on the iOS device. Please install and try again"];
                        [alert runModal];
                    });
                    [NSApp terminate:nil];
                }
                
                if (![self toolInstalled:@"removetweak"]) {
                    dispatch_sync(dispatch_get_main_queue(), ^(void){
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"Quit"];
                        [alert setMessageText:@"Error"];
                        [alert setInformativeText:@"removetweak is not installed on the iOS device. Please install and try again"];
                        [alert runModal];
                    });
                    [NSApp terminate:nil];
                }
            }

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
    NSString *command = [NSString stringWithFormat:@"if test -f /usr/bin/%@; then printf '%@ is installed'; fi", toolName, toolName];
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
    
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        return [input stringValue];
    } else {
        return nil;
    }
}
@end
