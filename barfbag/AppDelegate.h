//
//  AppDelegate.h
//  barfbag
//
//  Created by Lincoln Six Echo on 02.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarfBagParser.h"
#import "ATMHudDelegate.h"

@class ATMHud;
@class GenericTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,BarfBagParserDelegate,ATMHudDelegate> {

    UIWindow *window;
    GenericTabBarController *tabBarController;
    UIColor *themeColor;
    NSArray *scheduledConferences;
	ATMHud *hud;
}

@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) GenericTabBarController *tabBarController;
@property( strong, nonatomic ) UIColor *themeColor;
@property( retain, nonatomic ) NSArray *scheduledConferences;
@property( nonatomic, retain ) ATMHud *hud;

- (void) barfBagRefresh;
- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

@end
