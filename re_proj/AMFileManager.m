//
//  AMFileManager.m
//  re_proj
//
//  Created by Ander Moran on 4/10/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMFileManager.h"

@implementation AMFileManager
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createAMMainDirectory];
        [self createDecryptedDirectory];
        [self createHeadersDirectory];
        [self createTweaksDirectory];
        self.fridaDirectoryPath = [NSString stringWithFormat:@"%@/frida-ios-dump", self.mainDirectoryPath];
    }
    return self;
}

- (void)createAMMainDirectory {
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Target name"];
    NSFileManager *fm = [NSFileManager defaultManager];

    NSURL *dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0) {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:targetName];
        
        // If the directory does not exist, this method creates it.
        // This method is only available in macOS 10.7 and iOS 5.0 or later.
        NSError *error = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:NO
                           attributes:nil error:&error]) {
            // Handle the error.
            //NSLog(@"Unable to create directory at %@", [dirPath path]);
        }
    }
    _mainDirectoryPath = [dirPath path];
}

- (void)createDecryptedDirectory {
    NSError *error = nil;
    NSString *path = [NSString stringWithFormat:@"%@/Decrypted Binaries", _mainDirectoryPath];
    [self createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    _decryptedBinariesDirectoryPath = path;
}

- (void)createHeadersDirectory {
    NSError *error = nil;
    NSString *path = [NSString stringWithFormat:@"%@/Headers", _mainDirectoryPath];
    [self createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    _headersDirectoryPath = path;
}

+ (NSArray*)filesInDirectory:(NSString*)directoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray* files = [fm contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *filesList = [NSMutableArray arrayWithCapacity:[files count]];
    
    for (NSString *file in files) {
        NSString *path = [directoryPath stringByAppendingPathComponent:file];
        if ([fm fileExistsAtPath:path isDirectory:false]) {
            [filesList addObject:path];
        }
    }
    return [filesList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)createTweaksDirectory {
    NSError *error = nil;
    // Replace "Application Support" with "Application_Support" symlink bc theos hates spaces
    NSString *path = [NSString stringWithFormat:@"%@/Tweaks", _mainDirectoryPath];
    path = [path stringByReplacingOccurrencesOfString:@"Application Support"
                                           withString:@"Application-Support"];
    [self createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    _tweaksDirectoryPath = path;
}

- (NSString *)pathOfDecryptedBinaryForApp:(AMApp *)app {
    return [NSString stringWithFormat:@"%@/%@.ipa",
            [self decryptedBinariesDirectoryPath],
            app.displayName];
}

- (NSString *)pathOfHeaderForApp:(AMApp *)app {
    return [NSString stringWithFormat:@"%@/%@ headers",
            [self headersDirectoryPath],
            app.displayName];
}
@end
