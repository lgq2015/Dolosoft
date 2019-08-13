//
//  InitialViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/8/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "InitialViewController.h"


@implementation InitialViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [_waitingIndicator startAnimation:nil];
}

- (void)deviceDidAttachWithName:(NSString *)name {
    [_statusTextField setStringValue:[NSString stringWithFormat:@"%@ detected", name]];
//    [_waitingIndicator stopAnimation:nil];
//    [_waitingIndicator setHidden:YES];
}

- (void)setStatus:(NSString *)status {
    [_statusTextField setStringValue:status];
}

- (IBAction)retryButtonClicked:(id)sender {
    NSLog(@"clicked");
}

- (void)dismissSelfAndPresentMainVC:(AMMainViewController *)mainViewController {
    [mainViewController presentViewControllerAsModalWindow:mainViewController];
    [self dismissViewController:self];
}
@end
