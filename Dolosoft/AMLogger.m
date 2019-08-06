//
//  AMLogger.m
//  Dolosoft
//
//  Created by Ander Moran on 4/30/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMLogger.h"

@implementation AMLogger
- (instancetype)initWithFileManager:(AMFileManager *)fm {
    self = [super init];
    if (self) {
        fileManager = fm;
    }
    return self;
}
- (NSString *)logForApp:(AMApp *)app {
    NSString *source = [NSString stringWithFormat:@"%@/Documents/AMLog.txt", app.pathToAppStorageDir];
    NSString *dest = [NSString stringWithFormat:@"%@/AMLog.txt", [fileManager mainDirectoryPath]];
//    
//    NSLog(@"AM::Getting log");
//    NSLog(@"source = %@", source);
//    NSLog(@"dest = %@", dest);
    [_connectionHandler.session.channel downloadFile:source to:dest];
    NSString *logContent = [NSString stringWithContentsOfFile:dest encoding:NSUTF8StringEncoding error:nil];
    if (!logContent) {
        return @"";
    } else {
        return logContent;
    }
}
@end
