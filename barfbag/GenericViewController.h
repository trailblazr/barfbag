//
//  GenericViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface GenericViewController : UIViewController {


}

- (AppDelegate*) appDelegate;
- (UIColor*) themeColor;
- (UIColor*) brightColor;
- (UIColor*) darkColor;
- (void) alertWithTag:(NSInteger)tag title:(NSString*)title andMessage:(NSString*)message;
- (void) showActivityIndicator;
- (void) hideActivityIndicator;

@end
