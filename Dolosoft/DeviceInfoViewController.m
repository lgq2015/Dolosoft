//
//  DeviceInfoViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/12/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "DeviceInfoViewController.h"

@interface DeviceInfoViewController ()

@end

@implementation DeviceInfoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissController:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_deviceInfo count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"dictKey"]) {
        return [_deviceInfo allKeys][row];
    } else {
        if ([[[_deviceInfo allValues][row] className] isEqualToString:@"__NSCFNumber"]) { // bc default string formatter inserts commas into NSNumbers
            return [[_deviceInfo allValues][row] stringValue];
        }
        return [_deviceInfo allValues][row];
    }
    return @"(null)";
}

@end
