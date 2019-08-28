//
//  AppsCollectionView.h
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppsCollectionViewItem.h"
#import "AMManager.h"

NS_ASSUME_NONNULL_BEGIN

@class AMManager;

@interface AppsCollectionView : NSCollectionView
@property(retain,nonatomic) AMManager *manager;
@end

NS_ASSUME_NONNULL_END
