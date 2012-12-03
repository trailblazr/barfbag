//
//  AppDelegate.h
//  barfbag
//
//  Created by Lincoln Six Echo on 02.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarfBagParserXML.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,BarfBagParserXMLDelegate> {

    UIWindow *window;
    UITabBarController *tabBarController;
    UIColor *themeColor;
    NSMutableArray *scheduledEvents;
}

@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) UITabBarController *tabBarController;
@property( strong, nonatomic ) UIColor *themeColor;
@property( retain, nonatomic ) NSMutableArray *scheduledEvents;

- (void) barfBagRefresh;

@end
