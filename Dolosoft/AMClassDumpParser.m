//
//  AMClassDumpParser.m
//  re_proj
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMClassDumpParser.h"

@implementation AMClassDumpParser
+ (NSString *)getClassName:(NSString *)CDHeaderOutput {
    @try {
        
        NSString *className = [CDHeaderOutput matches:RX(@"(?<=@interface )[A-Z0-9_].+?(?= :)")][0];
//        NSLog(@"className = %@", className);
        return className;
    } @catch (NSException *e) {
        return nil;
    }
}

+ (NSString *)getSuperClassName:(NSString *)CDHeaderOutput {
    NSString *superClassName = [CDHeaderOutput matches:RX(@"(?<= : )[A-z0-9_]+")][0];
//    NSLog(@"superClassName = %@", superClassName);
    return superClassName;
}

+ (NSArray<AMObjcMethod *> *)getClassMethods:(NSString *)CDHeaderOutput forAMClass:(AMObjcClass *)AMClass {
    NSMutableArray *methodList = [[NSMutableArray alloc] init];
    
    NSArray* methods = [CDHeaderOutput matches:RX(@"[-+] \\([A-z0-9_].+(?=;)")];
//    NSLog(@"%ld", methods.count);
    for (int i = 0; i < methods.count; i++) {
        AMObjcMethod *objcMethod = [[AMObjcMethod alloc] init];
        NSString *returnType = [methods[i] matches:RX(@"(?<=[-+] \\()([A-z0-9 _*])+(?=\\))")][0];
        NSArray *matches = [methods[i] matchesWithDetails:RX(@"[+-] \\([A-z0-9_ ]+\\)([A-z0-9:.]+)?(?=\\(||;)|\\)[A-z0-9 _]+ ([A-z_0-9:]+)")]; // this is for methodName, need to rename this variable. too vague
        
        NSMutableString *methodName = [[NSMutableString alloc] init];
        
        for (int j = 0; j < [matches count]; j++) {
            RxMatch *match = matches[j];
            //NSLog(@"count = %ld", match.groups.count);
            for (int k = 1; k < match.groups.count; k++) {
                RxMatchGroup *matchGroup = match.groups[k];
                // don't start at 0 bc it isn't the group, it's the match
                if (matchGroup.value) {
                    [methodName appendFormat:@"%@", matchGroup.value];
                }

            }
        }

        NSArray *argumentTypes = [methods[i] matches:RX(@"(?<=:\\()[A-z0-9\\._ *]+(?=\\))")];
        
        objcMethod.callSyntax = methods[i];
        objcMethod.methodName = methodName;
        objcMethod.returnType = returnType;
        objcMethod.argumentTypes = argumentTypes;
        objcMethod.masterClass = AMClass;
        [methodList addObject:objcMethod];
    }
    NSArray *sortedMethodList;
    sortedMethodList = [methodList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(AMObjcMethod *)a methodName];
        NSString *second = [(AMObjcMethod *)b methodName];
        return [first compare:second];
    }];
    
    return [sortedMethodList copy];
}
@end
