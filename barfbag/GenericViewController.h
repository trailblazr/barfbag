//
//  GenericViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"
#import "ATMHud.h"

@class AppDelegate;

@interface GenericViewController : UIViewController <ATMHudDelegate> {

	ATMHud *hud;

}

@property( nonatomic, retain ) ATMHud *hud;

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

- (AppDelegate*) appDelegate;
- (void) alertWithTag:(NSInteger)tag title:(NSString*)title andMessage:(NSString*)message;
- (void) showActivityIndicator;
- (void) hideActivityIndicator;

- (NSString*) stringDayForDate:(NSDate*)date;
- (NSString*) stringShortDayForDate:(NSDate*)date;

- (UIColor*) backgroundColor;
- (UIColor*) themeColor;
- (UIColor*) brightColor;
- (UIColor*) brighterColor;
- (UIColor*) darkColor;
- (UIColor*) darkerColor;
- (UIColor*) backBrightColor;

@end
