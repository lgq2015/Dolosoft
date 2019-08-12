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
    _device = [[AMDevice alloc] init];
    // https://stackoverflow.com/questions/26689699/initializing-another-window-using-storyboard-for-os-x
    storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    _initialViewController = [storyBoard instantiateControllerWithIdentifier:@"InitialViewController"]; // instantiate your window controller
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

- (void)start {
    // Ok idk why this is in a thread and why i have 2 checks for if the device connected. Need to reformat
    [self setup];
    _mainViewController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"]; // instantiate your window controller
    _mainViewController.manager = self; // TODO: I hate the way this is structured, so restructure
    [_initialViewController dismissSelfAndPresentMainVC:_mainViewController];
    [_mainViewController.view.window orderFront:nil];
}



- (void)setup {
    /* leaving these here in case I need to reset the defaults */
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];
    
    if (!password) {
        password = [AMManager getSecureUserInput:@"Enter iOS device root password" defaultValue:@""];
        [defaults setObject:password forKey:@"password"];
        [defaults synchronize];
    }
    
    _fileManager = [[AMFileManager alloc] init];
    _appManager = [[AMAppManager alloc] initWithFileManager:_fileManager];
    _tweakBuilder = [[AMTweakBuilder alloc] initWithFileManager:_fileManager];
    _logger = [[AMLogger alloc] initWithFileManager:_fileManager];

    NSString *hostName = @"localhost";
    NSString *username = @"root";
    NSInteger port = 2222;
    
    _connectionHandler = [[AMConnectionHandler alloc]
                          initWithHost:hostName
                          port:port
                          username:username
                          password:password];
    
    while (!_connectionHandler.session.isConnected) { // we keep trying until we get the right password
        password = [AMManager getSecureUserInput:@"Incorrect iOS device root password. Please try again" defaultValue:@""];
        [defaults setObject:password forKey:@"password"];
        [defaults synchronize];
        _connectionHandler = [[AMConnectionHandler alloc] initWithHost:hostName
                                                                  port:port
                                                              username:username
                                                              password:password];
    }
    
    _deviceManager = [[AMDeviceManager alloc] initWithConnectionHandler:_connectionHandler fileManager:_fileManager];
    
    if (_connectionHandler.session.isConnected) { // TODO: Reformat this as this if statement is redundant
        _logger.connectionHandler = _connectionHandler;
        
        if ([_deviceManager toolsInstalled]) {
            NSLog(@"Dolosoft::DolosoftTools already installed on iOS device at /var/root/DolosoftTools");
        } else {
            [_deviceManager installTools];
        }
        
        _appManager.appList = [_deviceManager getUserApps];
        [_deviceManager addUserAppsDocumentsDirectory:_appManager];
        
    } else {
        NSLog(@"Dolosoft::Unable to establish connection.");
    }
}

+ (NSString *)getSecureUserInput:(NSString *)prompt defaultValue:(NSString *)defaultValue {
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
@end
