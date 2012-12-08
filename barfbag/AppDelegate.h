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
#import "BBJSONConnectOperation.h"
#import "BBJSONConnector.h"

@class ATMHud;
@class GenericTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,BarfBagParserDelegate,ATMHudDelegate,BBJSONConnectOperationDelegate> {

    UIWindow *window;
    GenericTabBarController *tabBarController;
    UIColor *themeColor;
    NSArray *scheduledConferences;
	ATMHud *hud;
    NSArray *semanticWikiAssemblies;
    NSArray *semanticWikiWorkshops;
    NSString *videoStreamsHtml;
    BOOL isAppStarting;
}

@property( nonatomic,assign ) BOOL isAppStarting;
@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) GenericTabBarController *tabBarController;
@property( strong, nonatomic ) UIColor *themeColor;
@property( retain, nonatomic ) NSArray *scheduledConferences;
@property( retain, nonatomic ) NSArray *semanticWikiAssemblies;
@property( retain, nonatomic ) NSArray *semanticWikiWorkshops;
@property( retain, nonatomic ) NSString *videoStreamsHtml;

@property( nonatomic, retain ) ATMHud *hud;

- (void) barfBagRefresh;
- (void) semanticWikiRefresh;
- (void) videoStreamsRefresh;
- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

@end
