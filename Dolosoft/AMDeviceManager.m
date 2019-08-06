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

- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManger:(AMFileManager *)manager{
    self = [super init];
    if (self) {
        connectionHandler = handler;
        fileManager = manager;
    }
    return self;
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
