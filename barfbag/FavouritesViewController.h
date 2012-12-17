//
//  FavouritesViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 07.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"

@interface FavouritesViewController : GenericTableViewController {
    
    NSArray *favouritesKeysArray;
    NSMutableDictionary *favouritesStored;
    UIButton *upNextButton;
    NSTimer *timerUpdateUpNextString;
}

@property( nonatomic, retain ) NSArray *favouritesKeysArray;
@property( nonatomic, retain ) NSMutableDictionary *favouritesStored;
@property( nonatomic, retain ) UIButton *upNextButton;
@property( nonatomic, retain ) NSTimer *timerUpdateUpNextString;

@end
