//
//  AMDeviceManager.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/2/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMConnectionHandler.h"
#import "AMFileManager.h"
#import "AMAppManager.h"

NS_ASSUME_NONNULL_BEGIN

@class AMAppManager;

@interface AMDeviceManager : NSObject {
    AMConnectionHandler *connectionHandler;
    AMFileManager *fileManager;
}
- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManger:(AMFileManager *)manager;
- (NSArray *)getUserApps;
- (void)addUserAppsDocumentsDirectory:(AMAppManager *)appManager;
- (BOOL)toolsInstalled;
- (void)installTools;
@end

NS_ASSUME_NONNULL_END
