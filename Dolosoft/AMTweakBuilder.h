//
//  AMTweakBuilder.h
//  Dolosoft
//
//  Created by Ander Moran on 4/29/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"

@class AMObjcMethod, AMMainViewController;

@interface AMTweakBuilder : NSObject {
    AMFileManager *fileManager;
}
@property(retain,nonatomic) AMMainViewController *mainViewController;
- (void)removeTheosProjectForApp:(AMApp *)app;
- (void)createTheosProjectForApp:(AMApp *)app;
- (void)makeDoTheosForApp:(AMApp *)app;
- (NSString *)formatSpecifierForObjectType:(NSString *)objectType;
- (NSString *)formatMethodForTweak:(AMObjcMethod *)method;
@end
