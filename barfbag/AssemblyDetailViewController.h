//
//  AssemblyDetailViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 09.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "GenericDetailViewController.h"
#import "Assembly.h"

@interface AssemblyDetailViewController : GenericTableViewController {

    GenericDetailViewController *detailHeaderViewController;
    Assembly *assembly;
    NSArray *sectionKeys;
    NSMutableDictionary *sectionArrays;
    NSString *navigationTitle;
}

@property( nonatomic, retain ) GenericDetailViewController *detailHeaderViewController;
@property( nonatomic, strong ) Assembly *assembly;
@property( nonatomic, retain ) NSArray *sectionKeys;
@property( nonatomic, retain ) NSMutableDictionary *sectionArrays;
@property( nonatomic, retain ) NSString *navigationTitle;

@end
