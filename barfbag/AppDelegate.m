//
//  AppDelegate.m
//  barfbag
//
//  Created by Lincoln Six Echo on 02.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "AppDelegate.h"

#import "FahrplanViewController.h"
#import "SettingsViewController.h"
#import "WelcomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController  = _tabBarController;
@synthesize themeColor = _themeColor;

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [_themeColor release];
    [super dealloc];
}

- (void) continueAfterWelcome {
    NSMutableArray *viewControllers = [NSMutableArray array];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [viewControllers addObject:[[[FahrplanViewController alloc] initWithNibName:@"FahrplanViewController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease]];
    }
    else {
        /*
         viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPad" bundle:nil] autorelease];
         viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPad" bundle:nil] autorelease];
         */
    }
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    _tabBarController.viewControllers = viewControllers;
    _window.alpha = 0.0f;
    _window.rootViewController = self.tabBarController;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _window.alpha = 1.0f;
        _tabBarController.tabBar.selectedImageTintColor = [self themeColor];
        _tabBarController.tabBar.tintColor = kCOLOR_BACK;
    } completion:^(BOOL finished) {
        // do nothing
    }];
}

- (CGFloat) randomFloatBetweenLow:(CGFloat)lowValue andHigh:(CGFloat)highValue {
    return (((CGFloat)arc4random()/0x100000000)*(highValue-lowValue)+lowValue);
}

- (UIColor*) randomColor {
    NSArray *colors = [NSArray arrayWithObjects:kCOLOR_VIOLET,kCOLOR_GREEN,kCOLOR_RED,kCOLOR_CYAN,kCOLOR_ORANGE,nil];
    NSInteger colorIndex = [[NSNumber numberWithFloat:(0.4+[self randomFloatBetweenLow:0.0 andHigh:4.0])] integerValue];
    return [colors objectAtIndex:colorIndex];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.themeColor = [self randomColor];
    WelcomeViewController *controller = [[[WelcomeViewController alloc] init] autorelease];
    _window.rootViewController = controller;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
