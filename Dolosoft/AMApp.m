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
- (id)initWithDisplayName:(NSString *)displayName executableName:(NSString *)executableName bundleIdentifier:(NSString *)bundleIdentifier pathToDir:(NSString *)pathToDir pathToExecutable:(NSString *)pathToExecutable {
    self = [super init];
    if (self) {
        AMFileManager *fileManager = [[AMFileManager alloc] init];
        self.displayName = displayName;
        self.executableName = executableName;
        self.bundleIdentifier = bundleIdentifier;
        self.pathToDir = pathToDir;
        self.pathToExecutable = pathToExecutable;
        self.headerPath = [NSString stringWithFormat:@"%@/%@ headers",
                           [fileManager headersDirectoryPath],
                           displayName];
        self.tweakPath = [NSString stringWithFormat:@"%@/%@",
                          [fileManager tweaksDirectoryPath],
                          @"amiosreversertemptweak/Tweak.xm"];
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
