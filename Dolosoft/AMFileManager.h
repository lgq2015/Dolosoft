//
//  AMFileManager.h
//  Dolosoft
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
@property(retain,nonatomic) NSString *fridaDirectoryPath;
@property(retain,nonatomic) NSString *stringsOutputPath;
- (instancetype)init;
- (void)createAMMainDirectory;
- (void)createDecryptedDirectory;
- (void)createHeadersDirectory;
- (void)createTweaksDirectory;
- (void)createApplicationSupportSymbolicLink;
- (void)createFridaDirectory;
- (BOOL)libimobiledeviceInstalled;
+ (NSArray *)filesInDirectory:(NSString*)directoryPath;
- (NSString *)pathOfDecryptedBinaryForApp:(AMApp *)app;
- (NSString *)pathOfHeaderForApp:(AMApp *)app;
@end
