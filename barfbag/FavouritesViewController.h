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
    
    NSMutableArray *favouritesArray;
}

@property( nonatomic, retain ) NSMutableArray *favouritesArray;

@end
