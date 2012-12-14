//
//  EventsViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"

@interface FahrplanViewController : GenericTableViewController <UISearchBarDelegate> {

    NSArray *sectionKeys;
    NSMutableDictionary *sectionArrays;

}

@property( nonatomic, retain ) NSArray *sectionKeys;
@property( nonatomic, retain ) NSMutableDictionary *sectionArrays;

- (IBAction) actionSearch:(id)sender;

@end
