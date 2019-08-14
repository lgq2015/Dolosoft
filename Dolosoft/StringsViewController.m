//
//  StringsViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/14/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "StringsViewController.h"

@interface StringsViewController ()

@end

@implementation StringsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_strings count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _strings[row];
}

- (IBAction)dismissButtonClicked:(id)sender {
    [self dismissController:self];
}

@end
