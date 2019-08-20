//
//  AMDeviceManager.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/2/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AMDeviceManager.h"

@implementation AMDeviceManager
- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManager:(AMFileManager *)manager{
    self = [super init];
    if (self) {
        connectionHandler = handler;
        fileManager = manager;
    }
    return self;
}

- (void)decryptAppAndDownload:(AMApp *)app {
    /*
     // I had this code running for iOS 10 devices
     // Assuming stefanesser's dumpdecrypted.dylib was located at /var/root/
     
     NSString *decryptCommand = [NSString stringWithFormat:
     @"cd /var/root/DolosoftDecrypted; \
     DYLD_INSERT_LIBRARIES=/var/root/dumpdecrypted.dylib \"%@\"", app.pathToExecutable];
     
     NSError *error = nil;
     [connectionHandler.session.channel execute:decryptCommand error:&error];
     
     // Here we download the decrypted binary to our machine
     NSString *dest = [NSString stringWithFormat:@"%@/%@.decrypted",
     fileManager.decryptedBinariesDirectoryPath,app.displayName];
     NSString *source = [NSString stringWithFormat:@"/var/root/DolosoftDecrypted/%@.decrypted",app.executableName];
     NSLog(@"source: %@", source);
     NSLog(@"dest: %@", dest);
     [connectionHandler.session.channel downloadFile:source
     to:dest];
     */
    
    /* for iOS 12 */
    NSString *command = [NSString stringWithFormat:@"./dump.py %@", app.bundleIdentifier];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.fridaDirectoryPath];
    [task setArguments:@[ @"-c", command ]];
    [task launch];
    
    // This waits for the task to finish before returning
    // We need to make sure the .ipa is zipped up before proceeding
    // The NSTask will complete before the file is fully outputted
    while ([task isRunning]) {}
    [NSThread sleepForTimeInterval:4.0f];
    
    //TODO: Do all of this using objective-c, this command line stuff is hacky
    command = [NSString stringWithFormat:@"mv \"%@/%@.ipa\" \"%@\"; unzip \"%@.ipa\"; mv Payload/*.app/%@ .; rm -r Payload; rm \"%@.ipa\"",
               fileManager.fridaDirectoryPath,
               app.displayName,
               fileManager.decryptedBinariesDirectoryPath,
               app.displayName,
               app.executableName,
               app.displayName];
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.decryptedBinariesDirectoryPath];
    [task setArguments:@[ @"-c", command ]];
    [task launch];
    
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
}

- (NSArray *)getUserApps {
    NSMutableArray<AMApp *> *userApps = [[NSMutableArray alloc] init];
    
    NSString *dest;
    NSArray<NSDictionary *> *installedAppsPlist;
    if (!TEST_MODE) {
        [connectionHandler.session.channel execute:@"getinstalledappsinfo" error:nil]; // TODO: make sure this package is installed on iOS device
        dest = [NSString stringWithFormat:@"%@/installed_apps.plist", [fileManager mainDirectoryPath]];
        [connectionHandler.session.channel downloadFile:@"/var/mobile/Documents/Dolosoft/installed_apps.plist" to:dest];
        installedAppsPlist = [NSArray arrayWithContentsOfFile:dest];
    } else {
        installedAppsPlist = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/installed_apps_debug.plist", [fileManager mainDirectoryPath]]];
    }

    for (NSDictionary *appInfo in installedAppsPlist) {
        NSString *displayName = appInfo[@"display-name"];
        // This is here because some apps (like Compass on iOS 12) do not have a display name
        if (!displayName) {
            displayName = appInfo[@"executable-name"];
        }
        AMApp *app = [[AMApp alloc] initWithDisplayName:displayName
                                         executableName:appInfo[@"executable-name"]
                                       bundleIdentifier:appInfo[@"bundle-identifier"]
                                              pathToBundleDir:appInfo[@"path"]
                                       pathToStorageDir:appInfo[@"storage-path"]
                                               iconData:appInfo[@"icon"]
                                            fileManager:fileManager];
        [userApps addObject:app];
    }
    
    NSArray *sortedArray;
    sortedArray = [userApps sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AMApp *)a displayName];
        NSString *second = [(AMApp *)b displayName];
        return [first caseInsensitiveCompare:second];
    }];
    NSLog(@"Got user's apps' info");
    return sortedArray;
}
@end
