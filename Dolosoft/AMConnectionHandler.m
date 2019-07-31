//
//  AMConnectionHandler.m
//  Dolosoft
//
//  Created by Ander Moran on 4/10/18.
//  Copyright © 2018 Ander Moran. All rights reserved.
//

#import "AMConnectionHandler.h"

@implementation AMConnectionHandler
- (instancetype)initWithHost:(NSString *)host port:(int)port username:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        [self initializeProxy];
        _session = [self initializeSessionWithHost:host
                                              port:port
                                          username:username
                                          password:password];
    }
    return self;
}
- (void)initializeProxy {
    //  Starts iproxy (make sure it is installed before hand)
    FILE *fp;
    fp = popen("/usr/local/bin/iproxy", "r");
    if (!fp) {
        NSLog(@"Unable to open /usr/local/bin/iproxy");
        exit(1);
    }
    
    const char *proxyCommand = "/usr/local/bin/iproxy 2222 22";
    system(proxyCommand);
    NSLog(@"iproxy started");
}

- (NMSSHSession *)initializeSessionWithHost:(NSString *)host port:(int)port username:(NSString *)username password:(NSString *)password {
    _session = [NMSSHSession connectToHost:[NSString stringWithFormat:@"%@:%d", host, port]
                                                         withUsername:username];
    if (_session.isConnected) {
        [_session authenticateByPassword:password];
        
        if (_session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        } else {
            NSLog(@"Authentication failed");
            return nil;
        }
    }
    return _session;
}
@end
