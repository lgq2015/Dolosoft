//
//  AMApp.h
//  Dolosoft
//
//  Created by Ander Moran on 4/11/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "AMObjcClass.h"
#import "AMFileManager.h"

@class AMObjcClass;

@interface AMApp : NSObject
@property(retain,nonatomic) NSString *displayName; // What appears on your iOS device's screen
@property(retain,nonatomic) NSString *displayNameLowercaseNoSpace;
@property(retain,nonatomic) NSString *executableName; // What the executable is called
@property(retain,nonatomic) NSString *bundleIdentifier; //com.companyname.yourapp
@property(retain,nonatomic) NSString *pathToDir; // path to .app
@property(retain,nonatomic) NSString *pathToExecutable; // path to executable
@property(retain,nonatomic) NSString *headerPath; // path to dumped header on mac
@property(retain,nonatomic) NSString *tweakFilePath; // path to the Tweak.x or Tweak.xm on mac
@property(retain,nonatomic) NSString *tweakDirPath; // path to the dolosoft_appname tweak directory on mac
@property(retain,nonatomic) NSString *pathToAppStorageDir; // path to the documents directory for the app
@property(retain,nonatomic) NSArray<AMObjcClass *> *classList;
- (id)initWithDisplayName:(NSString *)displayName executableName:(NSString *)executableName bundleIdentifier:(NSString *)bundleIdentifier pathToDir:(NSString *)pathToDir pathToExecutable:(NSString *)pathToExecutable;
- (AMObjcClass *)classWithName:(NSString *)name;
@end
