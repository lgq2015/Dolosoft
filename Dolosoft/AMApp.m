//
//  AMApp.m
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMApp.h"
#define LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

@implementation AMApp
- (id)initWithDisplayName:(NSString *)displayName executableName:(NSString *)executableName bundleIdentifier:(NSString *)bundleIdentifier pathToBundleDir:(NSString *)pathToBundleDir pathToStorageDir:(NSString *)pathToStorageDir iconData:(NSData *)iconData fileManager:(AMFileManager *)fileManager {
    self = [super init];
    if (self) {
        self.displayName = displayName;
        self.displayNameLowercaseNoSpace = [[displayName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        self.executableName = executableName;
        self.bundleIdentifier = bundleIdentifier;
        self.pathToDir = pathToBundleDir;
        self.pathToAppStorageDir = pathToStorageDir;
        self.icon = [[NSImage alloc] initWithData:iconData];
        self.pathToExecutable = [NSString stringWithFormat:@"%@/%@", pathToBundleDir, executableName];
        self.headerPath = [NSString stringWithFormat:@"%@/%@ headers",
                           [fileManager headersDirectoryPath],
                           displayName];
        self.tweakDirPath = [NSString stringWithFormat:@"%@/dolosoft%@",
                             [fileManager tweaksDirectoryPath],
                             self.displayNameLowercaseNoSpace];
        self.tweakFilePath = [NSString stringWithFormat:@"%@/Tweak.x", self.tweakDirPath];
    }
    return self;
}

- (AMObjcClass *)classWithName:(NSString *)name {
    for (AMObjcClass *class in self.classList) {
        if ([class.className isEqualToString:name]) {
            return class;
        }
    }
    return nil;
}
@end
