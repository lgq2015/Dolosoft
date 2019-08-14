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
    // Ok idk why this is in a thread and why i have 2 checks for if the device connected. Need to reformat
    [self setup];
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
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Attempting to connect to device via SSH"];
        });
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        static NSString *password;
        password = [defaults objectForKey:@"password"];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Prompting for mobile password"];
        });
        if (!password) {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                password = [AMManager getSecureUserInput:@"Enter iOS device mobile password"];
            });
            [defaults setObject:password forKey:@"password"];
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
                              password:password];

        while (!_connectionHandler.session.isConnected) { // we keep trying until we get the right password
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Prompting for mobile password"];
            });
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                password = [AMManager getSecureUserInput:@"Incorrect iOS device mobile password. Please try again"];
            });
            [defaults setObject:password forKey:@"password"];
            [defaults synchronize];
            _connectionHandler = [[AMConnectionHandler alloc] initWithHost:hostName
                                                                      port:port
                                                                  username:username
                                                                  password:password];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_initialViewController setStatus:@"Preparing device"];
        });
        
        _deviceManager = [[AMDeviceManager alloc] initWithConnectionHandler:_connectionHandler fileManager:_fileManager];

        if (_connectionHandler.session.isConnected) { // TODO: Reformat this as this if statement is redundant
            _logger.connectionHandler = _connectionHandler;

            // should put some check here to see if getinstalledappsinfo is installed on iOS device
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Getting list of installed apps"];
            });
            _appManager.appList = [_deviceManager getUserApps];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_initialViewController setStatus:@"Setup complete"];
            });
            NSLog(@"Dolosoft::Completed AMManager setup");
        } else {
            NSLog(@"Dolosoft::Unable to establish connection");
        }
    });
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
