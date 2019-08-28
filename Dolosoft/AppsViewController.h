//
//  AppsViewController.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppsCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@class AppsCollectionView;

@interface AppsViewController : NSViewController<NSCollectionViewDataSource, NSCollectionViewDelegate> {
    NSArray<AMApp *> *apps;
    IBOutlet AppsCollectionView *appsCollectionView;
}
- (IBAction)analyzeAppButtonClicked:(id)sender;
@property (retain, nonatomic) AMManager *manager;
@property (strong) IBOutlet NSButton *analyzeAppButton;

@end

NS_ASSUME_NONNULL_END
