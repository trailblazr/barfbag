//
//  EventDetailViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 09.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "GenericDetailViewController.h"
#import "Event.h"
#import "Day.h"

@interface EventDetailViewController : GenericTableViewController {

    Event *event;
    Day *day;
    UILabel *cellTextLabel;
    GenericDetailViewController *detailHeaderViewController;
    NSArray *sectionKeys;
    NSMutableDictionary *sectionArrays;
}

@property( nonatomic, retain ) Event *event;
@property( nonatomic, retain ) Day *day;
@property( nonatomic, retain ) UILabel *cellTextLabel;
@property( nonatomic, retain ) GenericDetailViewController *detailHeaderViewController;
@property( nonatomic, retain ) NSArray *sectionKeys;
@property( nonatomic, retain ) NSMutableDictionary *sectionArrays;


@end
