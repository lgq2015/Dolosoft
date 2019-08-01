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
    // TODO: Not related to this part but just wanted to remind myself to terminate all NSTasks when done using them!
    // Use NSTasks terminate method
    
    /*
        for the life of me I could not figure out how to extract only matched text with regex on the command line.
        (not sure why this was so hard to find on google????)
        this page saved me: https://www.commandlinefu.com/commands/view/13429/print-only-matched-pattern
        I am forever in your debt.
     
        I have this next peace of code to regex the number that needs to be inputted to create a tweak.
        I did this instead of hardcoding it because the number sometimes changes as theos updates.
    */
    // Here we get the number that needs to be inputted into the template to create the tweak
    NSPipe * outputPipe = [NSPipe pipe];
    NSTask *t = [[NSTask alloc] init];
    [t setStandardOutput:outputPipe];
    [t setLaunchPath:@"/bin/bash"];
    [t setCurrentDirectoryPath:@"/"];
    [t setArguments:@[ @"-l", @"-c", @"printf \"\" | $THEOS/bin/nic.pl 2> /dev/null | perl -ne '/(\\d+(?=.+tweak))/ && print \"$1\\n\";'" ]]; // I hated making this
    [t launch];
    
    NSFileHandle *fileHandle = [outputPipe fileHandleForReading];
    NSData *data = [fileHandle readDataToEndOfFile];
    int numberForCreateTweak = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue]; // TODO: This is ugly and I know there's a better way but dont have time to commit to it right now
    [t terminate];
    
    // Creating the tweak
    NSString *command = [NSString stringWithFormat:@"printf \"%d\\n%@\\n%@\\n%@\\n%@\\n%@\\n\" | $THEOS/bin/nic.pl ",
                         numberForCreateTweak,
                         @"amiosreverser-temp-tweak",
                         @"com.amiosreverser.amiosreverser-temp-tweak",
                         @"AMiOSReverser",
                         app.bundleIdentifier,
                         app.displayName
                         ];

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:fileManager.tweaksDirectoryPath];
    [task setArguments:@[ @"-l", @"-c", command ]]; // the "-l" argument loads the user's normal environment variables
    [task launch];
    /* TODO: rewrite NSTasks so that
     instead of [task setLaunchPath:@"/bin/bash"];
     it is [task setLaunchPath:@"/usr/local/bin/iproxy"];
     
     */
    
    
    // This waits for the task to finish before returning
    // TODO: See if I can replace with with NSTask's waitUntilExit method
    while ([task isRunning]) {}
    /* this part is to fix builds with Xcode 10
     https://github.com/theos/theos/issues/346
     */
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/amiosreversertemptweak/Makefile", [fileManager tweaksDirectoryPath]]];
//    [fileHandle seekToEndOfFile];
//    [fileHandle writeData:[@"amiosreversertemptweak_CFLAGS = -std=c++11 -stdlib=libc++\namiosreversertemptweak_LDFLAGS = -stdlib=libc++" dataUsingEncoding:NSUTF8StringEncoding]];
//    [fileHandle closeFile];
}

- (void)makeDoTheosForApp:(AMApp *)app {
    NSString *currentDir = [NSString stringWithFormat:@"%@/amiosreversertemptweak", [fileManager tweaksDirectoryPath]];
    /* for this to work properly you need to be able to run
     "make do" without theos requesting your password for
     your mobile device.
     The instructions are in this post: https://www.reddit.com/r/jailbreak/comments/47wc05/tutorial_setting_up_the_latest_version_of_theos/
     - on your Mac run:
        ssh-keygen -t rsa -b 2048
        ssh-copy-id root@localhost -p 2222
     - make sure to run:
        echo "export THEOS_DEVICE_IP=localhost" >> ~/.profile
        echo "export THEOS_DEVICE_PORT=2222" >> ~/.profile
     */
    NSString *command = [NSString stringWithFormat:@"cd %@/amiosreversertemptweak; make do", [fileManager tweaksDirectoryPath]];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:currentDir]; // leaving this here so I know I tried this. Does not work bc NSTask treats alias/symlink as the original dir which has a space which theos hates :))))
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
    } else if ([objectType isEqualToString:@"_Bool"]) {
        stringFormatSpecifier = @"%s";
    } else {
        
    }
    return stringFormatSpecifier;
}

- (NSString *)formatMethodForTweak:(AMObjcMethod *)method {
    NSMutableArray *argsThatAreBoolean = [[NSMutableArray alloc] init];
    
    NSMutableString *formattedMethod = [[NSMutableString alloc] init];
    [formattedMethod appendFormat:@"\n%@ {", method.callSyntax];
    NSString *specifier;
    
    if (![method.returnType isEqualToString:@"void"])  {
        [formattedMethod appendFormat:@"\n\t%@ returnedObj = %%orig;", method.returnType];
        specifier = [self formatSpecifierForObjectType:method.returnType];
        if ([method.returnType isEqualToString:@"_Bool"])  {
            [formattedMethod appendFormat:@"\n\tNSString *log = [NSString stringWithFormat:@\"(%@)[", specifier];
        } else {
            [formattedMethod appendFormat:@"\n\tNSString *log = [NSString stringWithFormat:@\"(<%%p>%@)[", specifier];
        }
    } else if ([method.returnType isEqualToString:@"void"]) {
        [formattedMethod appendString:@"\n\tNSString *log = [NSString stringWithFormat:@\"(void)["];
    }
    
    NSArray *methodArguments = [method.methodName componentsSeparatedByString:@":"];
    
    if (methodArguments.count == 1) {
        [formattedMethod appendFormat:@"%@", methodArguments[0]];
    }
    
    for (int i = 0; i < methodArguments.count - 1; i++) {
        NSString *methodArgument = methodArguments[i];
        specifier = [self formatSpecifierForObjectType:method.argumentTypes[i]];
        
        if ([method.argumentTypes[i] isEqualToString:@"_Bool"])  {
            [argsThatAreBoolean addObject:[NSNumber numberWithInteger:i]];
        }
        if (i == methodArguments.count - 2) {
            [formattedMethod appendFormat:@"%@:%@", methodArgument, specifier];
        } else {
            [formattedMethod appendFormat:@"%@:%@ ", methodArgument, specifier];
        }
    }
    
    if (![method.returnType isEqualToString:@"void"])  {
        if ([method.returnType isEqualToString:@"_Bool"])  {
            [formattedMethod appendString:@"];\", returnedObj ? \"YES\" : \"NO\""];
        } else {
            [formattedMethod appendString:@"];\", returnedObj, returnedObj"];
        }
    } else if ([method.returnType isEqualToString:@"void"]) {
        [formattedMethod appendString:@"];\""];
    }
    
    NSLog(@"ARR = %@", argsThatAreBoolean);
    for (int i = 1; i < methodArguments.count; i++) {
        // Using i-1 since this loop starts at index 1
        if ([argsThatAreBoolean containsObject:[NSNumber numberWithInteger:i-1]]) {
            [formattedMethod appendFormat:@", arg%d ? \"YES\" : \"NO\"", i];
        } else {
            [formattedMethod appendFormat:@", arg%d", i];
        }
    }
    
    [formattedMethod appendString:@"];"];
    [formattedMethod appendString:@"\n\tAMLog(log);"];
    
    if (![method.returnType isEqualToString:@"void"])  {
        [formattedMethod appendString:@"\n\treturn returnedObj;"];
    } else if ([method.returnType isEqualToString:@"void"]) {
        [formattedMethod appendString:@"\n\t%orig;"];
    }
    
    [formattedMethod appendFormat:@"\n}"];
    return [NSString stringWithString:formattedMethod];
}
@end
