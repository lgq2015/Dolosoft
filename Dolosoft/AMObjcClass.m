//
//  AMObjcClass.m
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMObjcClass.h"

@implementation AMObjcClass
- (instancetype)initWithClassDump:(NSString *)CDHeaderOutput {
    self = [super init];
    if (self) {
        self.className = [AMClassDumpParser getClassName:CDHeaderOutput];
        if (!self.className) {
//            NSLog(@"Nil class");
            return nil;
        }
        self.superClassName = [AMClassDumpParser getSuperClassName:CDHeaderOutput];
        
        @try {
            self.methodsList = [AMClassDumpParser getClassMethods:CDHeaderOutput forAMClass:self];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            NSLog(@"Ignoring the class %@ because of a parsing error. You can try to manually fix the header file.", self.className);
            return nil;
        }
        
    }
    return self;
}

- (AMObjcMethod *)methodWithName:(NSString *)name {
    for (AMObjcMethod *method in self.methodsList) {
        if ([method.methodName isEqualToString:name]) {
            return method;
        }
    }
    return nil;
}

-(NSString *)description {
    return self.className;
}
@end
