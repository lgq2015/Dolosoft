//
//  AMFileManager.m
//  Dolosoft
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
        [self createApplicationSupportSymbolicLink];
        _mainDirectoryPath = [_mainDirectoryPath stringByReplacingOccurrencesOfString:@"Application Support"
                                               withString:@"Application-Support"];
        [self createDecryptedDirectory];
        [self createHeadersDirectory];
        [self createTweaksDirectory];
        [self createFridaDirectory];
        _fridaDirectoryPath = [NSString stringWithFormat:@"%@/frida-ios-dump", self.mainDirectoryPath];
        _stringsOutputPath = [NSString stringWithFormat:@"%@/strings_output.txt", self.mainDirectoryPath];
    }
    return self;
}

- (void)createApplicationSupportSymbolicLink {
    /*
     Creates alias for "~/Library/Application Support" as "~/Library/Application Support"
     The "-" is needed because when theos tries to build a package, the path of the package
     cannot have a space in the name.
    */
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    NSString *applicationSupportSymbolicLinkDirectory = [applicationSupportDirectory stringByReplacingOccurrencesOfString:@"Application Support"
                                                                          withString:@"Application-Support"];
    
    if([self createSymbolicLinkAtPath:applicationSupportSymbolicLinkDirectory withDestinationPath:applicationSupportDirectory error:&error]) {
        NSLog(@"Dolosoft::Created Application-Support symlink at %@", applicationSupportSymbolicLinkDirectory);
    } else {
        if ([self fileExistsAtPath:applicationSupportSymbolicLinkDirectory]) {
            NSLog(@"Dolosoft::Application-Support symlink already exists");
        } else {
            NSLog(@"Dolosoft::Error creating Application-Support symlink\n%@", error);
        }
    }
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

- (void)createFridaDirectory {
    NSError *error;
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:@"/usr/bin/git"];
    task.arguments = @[ @"clone", @"https://github.com/andermoran/frida-ios-dump" ];
    task.currentDirectoryURL = [NSURL fileURLWithPath:_mainDirectoryPath];
    [task launchAndReturnError:&error];
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
    NSString *path = [NSString stringWithFormat:@"%@/Tweaks", _mainDirectoryPath];
    [self createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    _tweaksDirectoryPath = path;
}

- (NSString *)pathOfDecryptedBinaryForApp:(AMApp *)app {
    return [NSString stringWithFormat:@"%@/%@",
            [self decryptedBinariesDirectoryPath],
            app.executableName];
}

- (NSString *)pathOfHeaderForApp:(AMApp *)app {
    return [NSString stringWithFormat:@"%@/%@ headers",
            [self headersDirectoryPath],
            app.displayName];
}
@end
