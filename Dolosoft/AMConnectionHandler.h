//
//  AMConnectionHandler.h
//  Dolosoft
//
//  Created by Ander Moran on 4/10/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <NMSSH/NMSSH.h>

@interface AMConnectionHandler : NSObject {
    
}
@property(retain,nonatomic) NMSSHSession *session;
@property(retain,nonatomic) NSTask *iproxyTask;
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;
- (void)initializeProxy;
- (NMSSHSession *)initializeSessionWithHost:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;
@end
