//
//  AppDelegate.m
//  Dolosoft
//
//  Created by Ander Moran on 4/9/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AppDelegate.h"
#import "WaitingForDeviceViewController.h"
#import "AMDevice.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    AMDevice *device = [[AMDevice alloc] init];
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    if (device) { // if a device is connected
        AMMainViewController *viewController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"]; // instantiate your window controller
        viewController.device = device;
        [viewController presentViewControllerAsModalWindow:viewController];
    } else { // if no device is connected
        WaitingForDeviceViewController *viewController = [storyBoard instantiateControllerWithIdentifier:@"WaitingForDeviceViewController"]; // instantiate your window controller
        [viewController presentViewControllerAsModalWindow:viewController];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
