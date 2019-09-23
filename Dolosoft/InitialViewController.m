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
    [_deviceDetectedTextField performSelectorOnMainThread:@selector(setStringValue:) withObject:[NSString stringWithFormat:@"%@ detected", name] waitUntilDone:NO];
}

- (void)setStatus:(NSString *)status {
    [_statusTextField setStringValue:status];
}

- (IBAction)retryButtonClicked:(id)sender {
    NSLog(@"clicked");
}
@end
