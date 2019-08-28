//
//  AppsViewController.m
//  Dolosoft
//
//  Created by Moran, Ander on 8/28/19.
//  Copyright © 2019 Ander Moran. All rights reserved.
//

#import "AppsViewController.h"

@implementation AppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    apps = _manager.appManager.appList;
    
    // https://stackoverflow.com/questions/46433652/nscollectionview-does-not-scroll-items-past-initial-visible-rect
    if (@available(macOS 10.13, *)) {
        [appsCollectionView setFrameSize: appsCollectionView.collectionViewLayout.collectionViewContentSize];
    }
    
}

- (IBAction)analyzeAppButtonClicked:(id)sender {
    if (appsCollectionView.selectionIndexes.count == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"No app selected"];
        [alert runModal];
        return;
    }
    _manager.selectedApp = [apps objectAtIndex:[appsCollectionView.selectionIndexes firstIndex]];
    _manager.selectedClass = nil; // This is because I need to clear the methods table view after a new app selected
    [_manager.mainViewController.targetAppLabel setStringValue:[NSString stringWithFormat:@"Target app: %@", _manager.selectedApp.displayName]];
    [self dismissController:self];
    [_manager.mainViewController analyzeApp];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
    itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    AMApp *app = [apps objectAtIndex:indexPath.item];
    AppsCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"AppsCollectionViewItem"
                                                             forIndexPath:indexPath];
    [item.appNameLabel setStringValue:app.displayName];
    item.appIconView.image = app.icon;
    if (!item.appIconView.image) {
        item.appIconView.image = [NSImage imageNamed:@"icon_default.png"];
    }
    item.appIconView.wantsLayer = YES;
    item.appIconView.canDrawSubviewsIntoLayer = YES;
    item.appIconView.layer.cornerRadius = 20;
    item.appIconView.layer.masksToBounds = YES;
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(NSCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(NSCollectionView *)collectionView didEndDisplayingItem:(NSCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [apps count];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

@end
