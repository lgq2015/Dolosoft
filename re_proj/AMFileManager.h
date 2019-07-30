//
//  AMFileManager.h
//  re_proj
//
//  Created by Ander Moran on 4/10/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMApp.h"

@class AMApp;

@interface AMFileManager : NSFileManager
@property(retain,nonatomic) NSString *mainDirectoryPath;
@property(retain,nonatomic) NSString *decryptedBinariesDirectoryPath;
@property(retain,nonatomic) NSString *headersDirectoryPath;
@property(retain,nonatomic) NSString *tweaksDirectoryPath;
- (instancetype)init;
- (void)createAMMainDirectory;
- (void)createDecryptedDirectory;
- (void)createHeadersDirectory;
- (void)createTweaksDirectory;
+ (NSArray *)filesInDirectory:(NSString*)directoryPath;
- (NSString *)pathOfDecryptedBinaryForApp:(AMApp *)app;
- (NSString *)pathOfHeaderForApp:(AMApp *)app;
@end
