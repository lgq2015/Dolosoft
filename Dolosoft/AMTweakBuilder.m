//
//  AMTweakBuilder.m
//  Dolosoft
//
//  Created by Ander Moran on 4/29/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMTweakBuilder.h"

@implementation AMTweakBuilder
- (instancetype)init {
    self = [super init];
    if (self) {
        fileManager = [[AMFileManager alloc] init];
    }
    return self;
}

- (void)removeTheosProjectForApp:(AMApp *)app {
    NSString *theosProjectPath = [NSString stringWithFormat:@"%@/amiosreversertemptweak",
                                  [fileManager tweaksDirectoryPath]];
    [fileManager removeItemAtPath:theosProjectPath error:nil];
}

- (void)writeTheosCodeForApp:(AMApp *)app {
    // TODO: move function inside of buttonclicked in AMMainvVIewcontroller to here!!!!
}

- (void)createTheosProjectForApp:(AMApp *)app {
    [self removeTheosProjectForApp:app];
    NSString *command = [NSString stringWithFormat:@"printf \"%d\\n%@\\n%@\\n%@\\n%@\\n%@\\n\" | /opt/theos/bin/nic.pl ",
                         11,
                         @"amiosreverser-temp-tweak",
                         @"com.amiosreverser.amiosreverser-temp-tweak",
                         @"AMiOSReverser",
                         app.bundleIdentifier,
                         @"-"
                         ];
    
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.tweaksDirectoryPath];
    [task setArguments:@[ @"-c", command ]];
    [task launch];
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
    
    /* this part is to fix builds with Xcode 10
     https://github.com/theos/theos/issues/346
     */
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/amiosreversertemptweak/Makefile", [fileManager tweaksDirectoryPath]]];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[@"amiosreversertemptweak_CFLAGS = -std=c++11 -stdlib=libc++\namiosreversertemptweak_LDFLAGS = -stdlib=libc++" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

- (void)makeDoTheosForApp:(AMApp *)app {
    NSString *currentDir = [NSString stringWithFormat:@"%@/amiosreversertemptweak", [fileManager tweaksDirectoryPath]];
    
    NSString *command = [NSString stringWithFormat:@"cd %@; make do", currentDir];
    
    
    /* for this to work properly you need to be ablt to run
     "make do" without theos requesting your password for
     your mobile device. Look up how to do this.
     */
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:@"/Users/andermoran/Library/Application-Support/AMiOSReverser/Tweaks/amiosreversertemptweak"]; // leaving this here so I know I tried this. Does not work bc NSTask treats alias/symlink as the original dir which has a space which theos hates :))))
    [task setArguments:@[ @"-l", @"-c", command ]];
    [task launch];
    // This waits for the task to finish before returning
    while ([task isRunning]) {}
}

- (NSString *)formatSpecifierForObjectType:(NSString *)objectType {
    NSString *stringFormatSpecifier = @"%@";
    if ([objectType isEqualToString:@"int"]) {
        stringFormatSpecifier = @"%d";
    } else if ([objectType isEqualToString:@"float"]) {
        stringFormatSpecifier = @"%f";
    } else if ([objectType isEqualToString:@"double"]) {
        stringFormatSpecifier = @"%f";
    } else if ([objectType isEqualToString:@"long long"]) {
        stringFormatSpecifier = @"%lld";
    } else if ([objectType isEqualToString:@"unsigned long long"]) {
        stringFormatSpecifier = @"%llu";
    } else {
        
    }
    return stringFormatSpecifier;
}

- (NSString *)formatMethodForTweak:(AMObjcMethod *)method {
    NSMutableString *formattedMethod = [[NSMutableString alloc] init];
    [formattedMethod appendFormat:@"\n%@ {",method.callSyntax];
    
    if (![method.returnType isEqualToString:@"void"]) {
        [formattedMethod appendFormat:@"\n\t%@ returnedObj = %%orig;", method.returnType];
        NSString *specifier = [self formatSpecifierForObjectType:method.returnType];
        [formattedMethod appendFormat:@"\n\tNSString *log = [NSString stringWithFormat:@\"(<%%p>%@)[", specifier];
        
        NSArray *methodArguments = [method.methodName componentsSeparatedByString:@":"];
        
        if (methodArguments.count == 1) {
            [formattedMethod appendFormat:@"%@", methodArguments[0]];
        }
        
        for (int i = 0; i < methodArguments.count-1; i++) {
            NSString *methodArgument = methodArguments[i];
            specifier = [self formatSpecifierForObjectType:method.argumentTypes[i]];
            if (i == methodArguments.count-2) {
                [formattedMethod appendFormat:@"%@:%@", methodArgument, specifier];
            } else {
                [formattedMethod appendFormat:@"%@:%@ ", methodArgument, specifier];
            }
        }
        
        [formattedMethod appendString:@"];\", returnedObj, returnedObj"];
        
        for (int i = 1; i < methodArguments.count; i++) {
            [formattedMethod appendFormat:@", arg%d", i];
        }
        
        [formattedMethod appendString:@"];"];
        [formattedMethod appendString:@"\n\tAMLog(log);"];
        [formattedMethod appendString:@"\n\treturn returnedObj;"];
    }
    
    if ([method.returnType isEqualToString:@"void"]) {
        [formattedMethod appendString:@"\n\tNSString *log = [NSString stringWithFormat:@\"(void)["];
        
        NSArray *methodArguments = [method.methodName componentsSeparatedByString:@":"];
        
        if (methodArguments.count == 1) {
            [formattedMethod appendFormat:@"%@", methodArguments[0]];
        }
        
        for (int i = 0; i < methodArguments.count-1; i++) {
            NSString *methodArgument = methodArguments[i];
            NSString *specifier = [self formatSpecifierForObjectType:method.argumentTypes[i]];
            if (i == methodArguments.count-2) {
                [formattedMethod appendFormat:@"%@:%@", methodArgument, specifier];
            } else {
                [formattedMethod appendFormat:@"%@:%@ ", methodArgument, specifier];
            }
        }
        
        [formattedMethod appendString:@"];\""];
        
        for (int i = 1; i < methodArguments.count; i++) {
            [formattedMethod appendFormat:@", arg%d", i];
        }
        
        [formattedMethod appendString:@"];"];
        [formattedMethod appendString:@"\n\tAMLog(log);"];
        [formattedMethod appendString:@"\n\t%orig;"];
    }
    [formattedMethod appendFormat:@"\n}"];
    
    return [NSString stringWithString:formattedMethod];
}
@end
