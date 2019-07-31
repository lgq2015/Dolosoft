//
//  AMObjcClass.h
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMObjcMethod.h"
#import "AMClassDumpParser.h"

@class AMObjcMethod;

@interface AMObjcClass : NSObject
@property(retain,nonatomic) NSString *className;
@property(retain,nonatomic) NSString *superClassName;
@property(retain,nonatomic) NSArray<AMObjcMethod *> *methodsList;
- (instancetype)initWithClassDump:(NSString *)CDHeaderOutput;
- (AMObjcMethod *)methodWithName:(NSString *)name;
@end
