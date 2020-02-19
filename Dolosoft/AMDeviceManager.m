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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    static NSString *rootUserPassword; // this is the iOS device's root password
    rootUserPassword = [defaults objectForKey:@"rootUserPassword"];
    
    if (!rootUserPassword) {
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            rootUserPassword = [AMManager getSecureUserInput:@"Enter iOS device root password. This is REQUIRED by frida do decrypt the app. Everything else is done as the mobile user."];
        });
        [defaults setObject:rootUserPassword forKey:@"rootUserPassword"];
        [defaults synchronize];
    }
    
    NSError *error;
    NSString *command = [NSString stringWithFormat:@"./dump.py %@ -b --user root --password %@ --host %@ --port %ld --output-path \"%@\"", app.bundleIdentifier, rootUserPassword,
                         _manager.connectionHandler.hostName, _manager.connectionHandler.port, fileManager.decryptedBinariesDirectoryPath];
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
    task.arguments = @[ @"-c", command ];
    task.currentDirectoryURL = [NSURL fileURLWithPath:fileManager.fridaDirectoryPath];
    [task launchAndReturnError:&error];
//    NSLog(@"Error decrypt: %@",  [error localizedDescription]);
    
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
}

- (NSArray *)getUserApps{
    NSMutableArray<AMApp *> *userApps = [[NSMutableArray alloc] init];
    
    NSString *dest;
    NSArray<NSDictionary *> *installedAppsPlist;
    if (TEST_MODE) {
        installedAppsPlist = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/installed_apps_debug.plist", [fileManager mainDirectoryPath]]];
    } else {
        [connectionHandler.session.channel execute:@"getinstalledappsinfo" error:nil];
        dest = [NSString stringWithFormat:@"%@/installed_apps.plist", [fileManager mainDirectoryPath]];
        [connectionHandler.session.channel downloadFile:@"/var/mobile/Documents/Dolosoft/installed_apps.plist" to:dest];
        installedAppsPlist = [NSArray arrayWithContentsOfFile:dest];
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
                                            fileManager:fileManager
                                                version:appInfo[@"version"]];
        [userApps addObject:app];
    }
    
    NSArray *sortedArray;
    sortedArray = [userApps sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AMApp *)a displayName];
        NSString *second = [(AMApp *)b displayName];
        return [first caseInsensitiveCompare:second];
    }];
    TLog(@"Obtained user's apps' info");
    return sortedArray;
}
@end
