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
    NSArray *masterConfiguration;
}

@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) GenericTabBarController *tabBarController;
@property( strong, nonatomic ) UIColor *themeColor;
@property( retain, nonatomic ) NSArray *scheduledConferences;
@property( retain, nonatomic ) NSArray *semanticWikiAssemblies;
@property( retain, nonatomic ) NSArray *semanticWikiWorkshops;
@property( retain, nonatomic ) NSString *videoStreamsHtml;
@property( retain, nonatomic ) NSArray *masterConfiguration;

@property( nonatomic, retain ) ATMHud *hud;

- (BOOL) isConfigOnForKey:(NSString*)key defaultValue:(BOOL)isOn;
- (UIFont*) fontWithType:(CustomFontType)fontType andPointSize:(CGFloat)pointSize;

- (void) configRefresh;
- (void) configLoadCached;

- (void) allDataRefresh;
- (void) allDataLoadCached;

- (void) barfBagRefresh;
- (void) barfBagLoadCached;
- (void) semanticWikiRefresh;
- (void) semanticWikiLoadCached;
- (void) videoStreamsRefresh;
- (void) videoStreamsLoadCached;

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

- (UIColor*) backgroundColor;
- (UIColor*) brightColor;
- (UIColor*) brighterColor;
- (UIColor*) darkColor;
- (UIColor*) darkerColor;

@end
