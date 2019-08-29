//
//  AMClassDumpParser.h
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <RegExCategories/RegExCategories.h>
#import "AMObjcClass.h"

@class AMMainViewController;

@class AMObjcMethod;
@class AMObjcClass;

@interface AMClassDumpParser : NSObject
@property(retain,nonatomic) AMMainViewController *mainViewController;
+ (NSString *)getClassName:(NSString *)CDHeaderOutput;
+ (NSString *)getSuperClassName:(NSString *)CDHeaderOutput;
+ (NSArray<AMObjcMethod *> *)getClassMethods:(NSString *)CDHeaderOutput forAMClass:(AMObjcClass *)forAMClass;
@end
