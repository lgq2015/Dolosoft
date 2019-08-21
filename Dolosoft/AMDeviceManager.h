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
#import "AMManager.h"

@class AMAppManager;

@interface AMDeviceManager : NSObject {
    AMConnectionHandler *connectionHandler;
    AMFileManager *fileManager;
}
- (instancetype)initWithConnectionHandler:(AMConnectionHandler *)handler fileManager:(AMFileManager *)manager;
- (NSArray *)getUserApps;
- (void)decryptAppAndDownload:(AMApp *)app;
@end
