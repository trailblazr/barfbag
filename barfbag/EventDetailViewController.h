//
//  EventDetailViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 09.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "Event.h"

@interface EventDetailViewController : GenericTableViewController {

    Event *event;
    
}

@property( nonatomic, retain ) Event *event;

@end
