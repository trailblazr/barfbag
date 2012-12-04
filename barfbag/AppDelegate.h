//
//  AppDelegate.h
//  barfbag
//
//  Created by Lincoln Six Echo on 02.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarfBagParser.h"

@class GenericTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,BarfBagParserDelegate> {

    UIWindow *window;
    GenericTabBarController *tabBarController;
    UIColor *themeColor;
    NSArray *scheduledConferences;
}

@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) GenericTabBarController *tabBarController;
@property( strong, nonatomic ) UIColor *themeColor;
@property( retain, nonatomic ) NSArray *scheduledConferences;

- (void) barfBagRefresh;

@end
