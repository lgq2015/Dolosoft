//
//  AMAppManager.h
//  re_proj
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"
#import "AMFileManager.h"
#import "AMMainViewController.h"

@class AMMainViewController, AMFileManager, AMApp;

@interface AMAppManager : NSObject {
    AMFileManager *fileManager;
}
@property(retain,nonatomic) AMMainViewController *mainViewController;
@property(retain,nonatomic) NSArray<AMApp *> *appList;
- (void)initializeClassListForApp:(AMApp *)app;
- (void)dumpHeadersForApp:(AMApp *)app;
- (AMApp *)appWithDisplayName:(NSString *)displayName;
- (AMApp *)appWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

