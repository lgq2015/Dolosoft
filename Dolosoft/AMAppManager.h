//
//  AMAppManager.h
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"
#import "AMFileManager.h"

@class AMFileManager, AMApp;

@interface AMAppManager : NSObject {
    AMFileManager *fileManager;
}
@property(retain,nonatomic) NSArray<AMApp *> *appList;
- (instancetype)initWithFileManager:(AMFileManager *)fm;
- (void)initializeClassListForApp:(AMApp *)app;
- (void)dumpHeadersForApp:(AMApp *)app;
- (AMApp *)appWithDisplayName:(NSString *)displayName;
- (AMApp *)appWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

