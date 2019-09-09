//
//  AppDelegate.m
//  Dolosoft
//
//  Created by Ander Moran on 4/9/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

BOOL showTerminalInXCode = true;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Use the line below to switch to light mode
    // [NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    if (!showTerminalInXCode) {
        // https://stackoverflow.com/questions/7271528/how-to-nslog-into-a-file
        NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Target name"];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *dirPath = nil;
        NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                            inDomains:NSUserDomainMask];
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:targetName];
        NSString *pathForLog = [NSString stringWithFormat:@"%@/liveTerminalLog.txt", [dirPath path]];
        freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    }

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
