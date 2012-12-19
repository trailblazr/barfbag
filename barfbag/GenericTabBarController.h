//
//  GenericTabBarController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"
#import "ATMHud.h"

@class AppDelegate;

@interface GenericTabBarController : UITabBarController <ATMHudDelegate> {

    ATMHud *hud;
    NSDateFormatter *sharedDateFormatter;

}

@property( nonatomic, retain ) ATMHud *hud;
@property( nonatomic, retain ) NSDateFormatter *sharedDateFormatter;

- (NSDateFormatter*) dateFormatter;

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

- (AppDelegate*) appDelegate;

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
