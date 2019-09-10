//
//  AppDelegate.m
//  Dolosoft
//
//  Created by Ander Moran on 4/9/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Use the line below to switch to light mode
    // [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    if (TEST_MODE) {
        NSLog(@"[note] TEST_MODE enabled");
    }
    manager = [[AMManager alloc] init];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [manager.connectionHandler.iproxyTask terminate];
}
@end
