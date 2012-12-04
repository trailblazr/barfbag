//
//  GenericTableViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface GenericTableViewController : UITableViewController {

}

- (AppDelegate*) appDelegate;
- (UIColor*) themeColor;
- (UIColor*) brightColor;
- (UIColor*) darkColor;

@end
