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
    NSLog(@"%@", _deviceInfo);
    [deviceInfoTableView reloadData];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [deviceInfoTableView reloadData];
    // Do view setup here.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [deviceInfoTableView reloadData];
    // Do view setup here.
}

//- (void)tableViewSelectionDidChange:(NSNotification *)notification {
//}
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
        return [_deviceInfo allValues][row];
    }
    return @"ADSDDADASD";

}

@end
