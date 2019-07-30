//
//  AMLogger.h
//  AMiOSReverser
//
//  Created by Ander Moran on 4/30/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"
#import "AMFileManager.h"
#import "AMConnectionHandler.h"

@interface AMLogger : NSObject {
    AMFileManager *fileManager;
}
@property (retain, nonatomic) AMConnectionHandler *connectionHandler;
- (instancetype)init;
- (NSString *)logForApp:(AMApp *)app;
@end
