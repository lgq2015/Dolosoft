//
//  AMObjcMethod.h
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMObjcClass.h"

@class AMObjcClass;

@interface AMObjcMethod : NSObject
@property(retain,nonatomic) NSString *callSyntax;
@property(retain,nonatomic) NSString *methodName;
@property(retain,nonatomic) NSArray<NSString *> *argumentTypes;
@property(retain,nonatomic) NSString *returnType;
@property(retain,nonatomic) AMObjcClass *masterClass; // The class that owns this method
@end
