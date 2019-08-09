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
#import "XMLReader.h"

NS_ASSUME_NONNULL_BEGIN

@class AMAppManager;

@interface AMDeviceManager : NSObject {
    AMConnectionHandler *connectionHandler;
    AMFileManager *fileManager;
}
- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManager:(AMFileManager *)manager;
- (NSArray *)getUserApps;
- (void)addUserAppsDocumentsDirectory:(AMAppManager *)appManager;
- (BOOL)toolsInstalled;
- (void)installTools;
- (void)decryptAppAndDownload:(AMApp *)app;
@end

NS_ASSUME_NONNULL_END
