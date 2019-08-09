//
//  AMAppManager.m
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMAppManager.h"

@implementation AMAppManager
- (instancetype)initWithFileManager:(AMFileManager *)fm {
    self = [super init];
    if (self) {
        fileManager = fm;
    }
    return self;
}

- (void)initializeClassListForApp:(AMApp *)app {
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@ headers/", [fileManager headersDirectoryPath], app.displayName];
    NSMutableArray<AMObjcClass*> *classList = [[NSMutableArray alloc] init];
    NSArray *headerFilePaths = [AMFileManager filesInDirectory:directoryPath];
    for (NSString *headerFilePath in headerFilePaths) {
        NSString *CDHeaderOutput = [NSString stringWithContentsOfFile:headerFilePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
        AMObjcClass *objcClass = [[AMObjcClass alloc] initWithClassDump:CDHeaderOutput];

        if (objcClass) {
            [classList addObject:objcClass];
        }
    }
    app.classList = [classList copy];
}

- (void)dumpHeadersForApp:(AMApp *)app {
    NSString *decryptedBinaryPath = [NSString stringWithFormat:@"%@/%@",
                                     [fileManager decryptedBinariesDirectoryPath],
                                     app.executableName];
    
    NSString *dumpPath = [NSString stringWithFormat:@"%@/%@ headers",
                          [fileManager headersDirectoryPath],
                          app.displayName];
    
    NSString *command = [NSString stringWithFormat:@"/usr/local/bin/class-dump -Hs -o \"%@\" \"%@\"",
                         dumpPath,
                         decryptedBinaryPath];
    
    NSString *directory = [NSString stringWithFormat:@"%@", [fileManager headersDirectoryPath]];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:directory];
    [task setArguments:@[ @"-c", command ]];
    [task launch];
    
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
}

- (AMApp *)appWithDisplayName:(NSString *)displayName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName == %@", displayName];
    NSArray *filteredArray = [self.appList filteredArrayUsingPredicate:predicate];
    AMApp *app = filteredArray[0];
    return app;
}

- (AMApp *)appWithBundleIdentifier:(NSString *)bundleIdentifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == %@", bundleIdentifier];
    NSArray *filteredArray = [self.appList filteredArrayUsingPredicate:predicate];
    if ([filteredArray count]) {
        AMApp *app = filteredArray[0];
        return app;
    }
    return nil;

}
@end
