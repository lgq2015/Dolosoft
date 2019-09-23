//
//  PreferencesViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/29/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "PreferencesViewController.h"

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    defaults = [NSUserDefaults standardUserDefaults];
    themeMode = [defaults objectForKey:@"themeMode"];
    if (!themeMode) {
        if ([NSAppearance.currentAppearance.name isEqualToString:@"NSAppearanceNameAqua"]) {
            themeMode = @"Light";
        } else {
            themeMode = @"Dark";
        }
    }
    NSLog(@"themeMode = %@", themeMode);
    [_themeButton selectItemWithTitle:themeMode];
}

- (IBAction)themeButtonChanged:(id)sender {
    themeMode = _themeButton.selectedItem.title;
    if ([themeMode isEqualToString:@"Light"]) {
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    } else if ([themeMode isEqualToString:@"Dark"]) {
        [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }
    
    [defaults setObject:themeMode forKey:@"themeMode"];
    [defaults synchronize];
}

@end
