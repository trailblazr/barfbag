//
//  FavouritesViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 07.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "SearchableItem.h"

@interface FavouritesViewController : GenericTableViewController {
    
    NSArray *favouritesKeysArray;
    NSMutableDictionary *favouritesStored;
    UIButton *upNextButton;
    NSTimer *timerUpdateUpNextString;
    NSInteger numOfRefreshes;
    SearchableItem *itemUpNext;
    UIView *cachedTableFooter;
    UIView *cachedTableHeader;
}

@property( nonatomic, assign ) NSInteger numOfRefreshes;
@property( nonatomic, retain ) NSArray *favouritesKeysArray;
@property( nonatomic, retain ) NSMutableDictionary *favouritesStored;
@property( nonatomic, retain ) UIButton *upNextButton;
@property( nonatomic, retain ) NSTimer *timerUpdateUpNextString;
@property( nonatomic, retain ) SearchableItem *itemUpNext;
@property( nonatomic, retain ) UIView *cachedTableFooter;
@property( nonatomic, retain ) UIView *cachedTableHeader;

@end
