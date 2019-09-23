//
//  PreferencesViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/29/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesViewController : NSViewController {
    NSUserDefaults *defaults;
    NSString *themeMode;
}
@property (strong) IBOutlet NSPopUpButton *themeButton;
@end

NS_ASSUME_NONNULL_END
