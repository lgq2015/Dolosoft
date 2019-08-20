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
- (NSString *)retrieveLogForApp:(AMApp *)app {
    NSString *source = [NSString stringWithFormat:@"%@/Documents/AMLog.txt", app.pathToAppStorageDir];
    NSString *dest = [NSString stringWithFormat:@"%@/AMLog.txt", [fileManager mainDirectoryPath]];

    [_connectionHandler.session.channel downloadFile:source to:dest];
    NSString *logContent = [NSString stringWithContentsOfFile:dest encoding:NSUTF8StringEncoding error:nil];
    if (!logContent) {
        return @"";
    } else {
        return logContent;
    }
}

- (void)removeLogForApp:(AMApp *)app {
    NSString *logFilePathOnDevice = [NSString stringWithFormat:@"%@/Documents/AMLog.txt", app.pathToAppStorageDir];
    NSString *command = [NSString stringWithFormat:@"rm %@", logFilePathOnDevice];
    [_connectionHandler.session.channel execute:command error:nil];
    NSLog(@"Removed AMLog.txt from %@'s Documents directory", app.displayName);
}
@end
