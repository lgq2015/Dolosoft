//
//  InitialLoadingViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "InitialLoadingViewController.h"


@implementation InitialLoadingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"LOADED");
    [_waitingIndicator startAnimation:nil];
    [self performSelectorInBackground:@selector(checkForDevice) withObject:nil];
    // runt thread here that checks if device is not null
}
- (void)checkForDevice {
    while (true) {
        _device = [[AMDevice alloc] init];
        if (_device) {
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
    AMMainViewController *viewController;
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    viewController = [storyBoard instantiateControllerWithIdentifier:@"AMMainViewController"]; // instantiate your window controller
    viewController.device = _device;
    [viewController presentViewControllerAsModalWindow:viewController];
    [self dismissViewController:self];
}
@end
