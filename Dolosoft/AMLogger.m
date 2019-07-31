//
//  AMLogger.m
//  AMiOSReverser
//
//  Created by Ander Moran on 4/30/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMLogger.h"

@implementation AMLogger
- (instancetype)init {
    self = [super init];
    if (self) {
        fileManager = [[AMFileManager alloc] init];
    }
    return self;
}
- (NSString *)logForApp:(AMApp *)app {
    NSString *source = [NSString stringWithFormat:@"%@/Documents/AMLog.txt", app.pathToAppStorageDir];
    NSString *dest = [NSString stringWithFormat:@"%@/AMLog.txt", [fileManager mainDirectoryPath]];
    
//    NSLog(@"AM::Getting log");
//    NSLog(@"source = %@", source);
//    NSLog(@"dest = %@", dest);
    [_connectionHandler.session.channel downloadFile:source to:dest];
    return [NSString stringWithContentsOfFile:dest encoding:NSUTF8StringEncoding error:nil];
}
@end
