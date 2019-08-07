//
//  AMDeviceManager.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/2/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AMDeviceManager.h"

#define TEST_MODE NO

@implementation AMDeviceManager
- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManger:(AMFileManager *)manager{
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
    //    make sure to have glib installed via Cydia
    
    NSError *error = nil;
    NSString *response;
    if (TEST_MODE) {
        response = @"Piq\nPiq\ncom.andermoran.piqme\n/var/containers/Bundle/Application/88777CE8-DA4E-4E2D-A002-477D870418A2/Piq.app\n/var/containers/Bundle/Application/88777CE8-DA4E-4E2D-A002-477D870418A2/Piq.app/Piq\nChrome\nChrome\ncom.google.chrome.ios\n/var/containers/Bundle/Application/30E66BC2-7998-4CC6-9565-4F05D982A546/stable.app\n/var/containers/Bundle/Application/30E66BC2-7998-4CC6-9565-4F05D982A546/stable.app/Chrome";
    } else {
        response = [connectionHandler.session.channel execute:@"DolosoftTools/userapps.sh" error:&error];
    }
    
    NSArray *lines = [response componentsSeparatedByString: @"\n"];
    NSMutableArray *apps = [[NSMutableArray alloc] init];
    
    for (int i = 0; i+4 < [lines count]; i+=5) {
        AMApp *app = [[AMApp alloc] initWithDisplayName:lines[i]
                                         executableName:lines[i+1]
                                       bundleIdentifier:lines[i+2]
                                              pathToDir:lines[i+3]
                                       pathToExecutable:lines[i+4]];
        
        if ([app.displayName isEqualToString:@"(null)"]) {
            app.displayName = app.executableName;
        }
        [apps addObject:app];
    }
    
    NSArray *sortedArray;
    sortedArray = [apps sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AMApp *)a displayName];
        NSString *second = [(AMApp *)b displayName];
        return [first compare:second];
    }];
    NSLog(@"Got user's apps' info");
    return sortedArray;
}

- (void)addUserAppsDocumentsDirectory:(AMAppManager *)appManager {
    NSError *error = nil;
    NSString *response;
    if (TEST_MODE) {
        response = @"/var/mobile/Containers/Data/Application/D885F73F-B14A-4CB7-9AD7-B53498ED2B19\ncom.andermoran.piqme\n/var/mobile/Containers/Data/Application/37B44BA7-53D4-455A-B740-210690543215\ncom.google.chrome.ios\n";
    } else {
        response = [connectionHandler.session.channel execute:@"DolosoftTools/userappsextended.sh" error:&error];
    }
    
    NSArray *lines = [response componentsSeparatedByString: @"\n"];
    
    for (int i = 0; i+1 < [lines count]; i+=2) {
        NSString *documentDir = lines[i];
        //        NSLog(@"documentDir = %@", documentDir);
        NSString *bundleIdentifier = lines[i+1];
        //        NSLog(@"bundleIdentifier = %@", bundleIdentifier);
        AMApp *app = [appManager appWithBundleIdentifier:bundleIdentifier];
        //        NSLog(@"app = %@", app);
        if (app) {
            app.pathToAppStorageDir = documentDir;
        }
    }
}

- (BOOL)toolsInstalled {
    NSString *response = [connectionHandler.session.channel
                          execute:@"if [ -d /var/root/DolosoftTools ]; then echo '/var/root/DolosoftTools exists'; fi"
                          error:nil];
    
    if ([response isEqualToString:@"/var/root/DolosoftTools exists\n"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)installTools {
    NSLog(@"/var/root/DolosoftTools does not exist on iOS device. Uploading them now.");
    [connectionHandler.session.channel
     execute:@"mkdir /var/root/DolosoftTools"
     error:nil];
    
    BOOL success_userapps = [connectionHandler.session.channel
                             uploadFile:[NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]
                             to:@"/var/root/DolosoftTools/"];
    if (success_userapps) {
        NSLog(@"Uploaded %@ to /var/root/DolosoftTools/userapps.sh on iOS device",
              [NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]);
        [connectionHandler.session.channel
         execute:@"chmod +x /var/root/DolosoftTools/userapps.sh"
         error:nil];
    } else {
        NSLog(@"Failed to upload %@ to /var/root/DolosoftTools/userapps.sh on iOS device",
              [NSString stringWithFormat:@"%@/DolosoftTools/userapps.sh", [fileManager mainDirectoryPath]]);
    }
    
    BOOL success_userappsextended = [connectionHandler.session.channel
                                     uploadFile:[NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]
                                     to:@"/var/root/DolosoftTools/"];
    if (success_userappsextended) {
        NSLog(@"Uploaded %@ to /var/root/DolosoftTools/userappsextended.sh on iOS device",
              [NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]);
        [connectionHandler.session.channel
         execute:@"chmod +x /var/root/DolosoftTools/userappsextended.sh"
         error:nil];
    } else {
        NSLog(@"Failed to upload %@ to /var/root/DolosoftTools/userappsextended.sh on iOS device",
              [NSString stringWithFormat:@"%@/DolosoftTools/userappsextended.sh", [fileManager mainDirectoryPath]]);
    }
}
@end
