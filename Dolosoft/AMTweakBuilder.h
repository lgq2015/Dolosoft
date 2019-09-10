//
//  AMTweakBuilder.h
//  Dolosoft
//
//  Created by Ander Moran on 4/29/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"
#import "AMManager.h"


@class AMObjcMethod, AMMainViewController, AMManager;

@interface AMTweakBuilder : NSObject {
    AMFileManager *fileManager;
}
@property(retain, nonatomic) AMManager *manager;
- (instancetype)initWithFileManager:(AMFileManager *)fm;
- (void)removeTheosProjectForApp:(AMApp *)app;
- (void)createTheosProjectForApp:(AMApp *)app;
- (void)writeTweakCodeForApp:(AMApp *)app forObjcClass:(AMObjcClass *)objcClass withMethods:(NSArray<AMObjcMethod *> *)methods;
- (void)makeDoTheosForApp:(AMApp *)app;
- (NSString *)formatSpecifierForObjectType:(NSString *)objectType;
- (NSString *)formatMethodForTweak:(AMObjcMethod *)method;
@end
