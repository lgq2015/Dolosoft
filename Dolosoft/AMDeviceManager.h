//
//  AMDeviceManager.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/2/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMDeviceManager : NSObject
- (BOOL)toolsInstalled;
- (void)installTools;
@end

NS_ASSUME_NONNULL_END
