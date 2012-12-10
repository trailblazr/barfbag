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
#import "JSONAssembly.h"

@interface AssemblyDetailViewController : GenericTableViewController {

    GenericDetailViewController *detailHeaderViewController;
    JSONAssembly *assembly;
    NSArray *sectionKeys;
    NSMutableDictionary *sectionArrays;
}

@property( nonatomic, retain ) GenericDetailViewController *detailHeaderViewController;
@property( nonatomic, retain ) JSONAssembly *assembly;
@property( nonatomic, retain ) NSArray *sectionKeys;
@property( nonatomic, retain ) NSMutableDictionary *sectionArrays;

@end
