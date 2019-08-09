//
//  WaitingForDeviceViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "WaitingForDeviceViewController.h"


@implementation WaitingForDeviceViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"LOADED");
    [_waitingIndicator startAnimation:nil];
    [self performSelectorInBackground:@selector(checkForDevice) withObject:nil];
    // runt thread here that checks if device is not null
}
- (void)checkForDevice {
    while (true) {
        NSLog(@"HEREEE");
        self.device = [[AMDevice alloc] init];
        if (self.device) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self dismissSelfAndPresentMainVC];
                });
            });
            return;
        }
    }
}
- (void)dismissSelfAndPresentMainVC {
    NSViewController *myController;
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    myController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"]; // instantiate your window controller
    [myController presentViewControllerAsModalWindow:myController];
    [self dismissViewController:self];
}
@end
