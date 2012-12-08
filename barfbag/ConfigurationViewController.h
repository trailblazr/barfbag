//
//  ConfigurationViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"

@interface ConfigurationViewController : GenericTableViewController {

    NSMutableArray *sectionsArray;

}

@property( nonatomic, retain ) NSMutableArray *sectionsArray;

@end
