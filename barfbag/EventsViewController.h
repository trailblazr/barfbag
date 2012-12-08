//
//  EventsViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"

@interface EventsViewController : GenericTableViewController <UISearchBarDelegate> {

    BOOL isSearching;

}

@property( nonatomic, assign ) BOOL isSearching;


- (IBAction) actionSearch:(id)sender;
- (void) searchFilterEventsDisplayed;

@end
