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
}

@property( nonatomic, retain ) NSArray *favouritesKeysArray;
@property( nonatomic, retain ) NSMutableDictionary *favouritesStored;

@end
