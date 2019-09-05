//
//  AMConnectionHandler.m
//  Dolosoft
//
//  Created by Ander Moran on 4/10/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMConnectionHandler.h"

@implementation AMConnectionHandler
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        [self initializeProxy];
        _hostName = host;
        _username = username;
        _port = port;
        _session = [self initializeSessionWithHost:host
                                              port:port
                                          username:username
                                          password:password];
    }
    return self;
}
- (void)initializeProxy {
    /*      If the user does not have iproxy installed then we use our own */
//    NSBundle *main = [NSBundle mainBundle];
//    NSString *iproxyPath = [main pathForAuxiliaryExecutable:@"Resources/iproxy"];
//    NSError *error = nil;
//    _iproxyTask = [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:iproxyPath]
//                                              arguments:@[ @"2222", @"22" ]
//                                                  error:&error
//                                     terminationHandler:^(NSTask *t){}];
    NSError *error = nil;
    _iproxyTask = [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/local/bin/iproxy"]
                                arguments:@[ @"2222", @"22" ]
                                    error:&error
                       terminationHandler:^(NSTask *t){}];
    if (error) {
        NSLog(@"Dolosoft::Error starting iproxy, make sure iproxy exists at /usr/local/bin/iproxy - %@", [error localizedDescription]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Exit"];
        [alert setMessageText:[NSString stringWithFormat:@"Error starting iproxy, make sure iproxy exists at /usr/local/bin/iproxy - %@\nIf you haven't already, run \"brew install libimobiledevice\" on your Mac.", [error localizedDescription]]];
        [alert runModal];
        [NSApp terminate:nil];
    } else {
        [NSThread sleepForTimeInterval:0.01f]; // Need this because iproxy starts but isn't immediately ready to connect, this sleep gives it time
    }
}

- (NMSSHSession *)initializeSessionWithHost:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password {
    NMSSHSession *session = [NMSSHSession connectToHost:[NSString stringWithFormat:@"%@:%ld", host, (long)port]
                                           withUsername:username];
    if (session.isConnected) {
        [session authenticateByPassword:password];
        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        } else {
            NSLog(@"Authentication failed");
            return nil;
        }
    }
    return session;
}
@end
