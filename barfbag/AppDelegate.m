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
#import "SinaURLConnection.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController  = _tabBarController;
@synthesize themeColor = _themeColor;
@synthesize scheduledEvents;

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [_themeColor release];
    self.scheduledEvents = nil;
    [super dealloc];
}

#pragma mark - Convenience & Helper Methods

- (CGFloat) randomFloatBetweenLow:(CGFloat)lowValue andHigh:(CGFloat)highValue {
    return (((CGFloat)arc4random()/0x100000000)*(highValue-lowValue)+lowValue);
}

- (UIColor*) randomColor {
    NSArray *colors = [NSArray arrayWithObjects:kCOLOR_VIOLET,kCOLOR_GREEN,kCOLOR_RED,kCOLOR_CYAN,kCOLOR_ORANGE,nil];
    NSInteger colorIndex = [[NSNumber numberWithFloat:(0.4+[self randomFloatBetweenLow:0.0 andHigh:4.0])] integerValue];
    return [colors objectAtIndex:colorIndex];
}

- (void) addUserAgentInfoToRequest:(NSMutableURLRequest*)request {
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appPlatform = [[UIDevice currentDevice] platformString];
	NSString *appSystemVersion = [[UIDevice currentDevice] systemVersion];
	NSString *appLanguageContext = [[NSLocale currentLocale] localeIdentifier];
	
	NSString *uaString = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; %@)", appName, appVersion, appPlatform, appSystemVersion, appLanguageContext];
	if( DEBUG ) NSLog( @"BARFBAG: USER AGENT = %@", uaString );
	[request setValue:uaString forHTTPHeaderField:@"User-Agent"];
	
}


#pragma mark - XMLParserDelegate

- (void) xmlParser:(BarfBagParserXML *)parser addEvent:(Event *)event {
    [scheduledEvents addObject:event];
}

- (void) xmlParser:(BarfBagParserXML*)parser setAllEvents:(NSMutableArray*)events {
    self.scheduledEvents = events;
}

#pragma mark - Fetching, Caching & Parsing of XML

-(void) barfBagFillCached:(BOOL)isCachedContent {
    if( DEBUG ) NSLog( @"BARFBAG: PARSING..." );
    NSString *pathToStoredFile = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_CACHED_FAHRPLAN]; // CACHE .xml file
    // PREPARE PARSING
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToStoredFile]];
    BarfBagParserXML *parser = [[BarfBagParserXML alloc] initXMLParserWithDelegate:self];
    [xmlParser setDelegate:parser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_STARTED object:self];
    BOOL success = [xmlParser parse];
    
    if( success ) {
        if( DEBUG ) NSLog( @"BARFBAG: PARSING SUCCEEDED." );
        NSString *versionCurrent = [[NSUserDefaults standardUserDefaults] stringForKey:kUSERDEFAULT_KEY_DATA_VERSION_CURRENT];
        NSString *versionUpdated = [[NSUserDefaults standardUserDefaults] stringForKey:kUSERDEFAULT_KEY_DATA_VERSION_UPDATED];
        BOOL hasNewDataVersion = ![versionCurrent isEqualToString:versionUpdated];
        
        [[NSUserDefaults standardUserDefaults] setObject:versionUpdated forKey:kUSERDEFAULT_KEY_DATA_VERSION_CURRENT];
        
        if( hasNewDataVersion ) { // UPDATE LOCAL NOTIFICATIONS
            BOOL shouldRescheduleAndCheckLocalNotifications = NO;
            if( shouldRescheduleAndCheckLocalNotifications ) {
                /*
                NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"favorites"];
                NSMutableArray *favoritesArray = [[NSMutableArray alloc] init];
                
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                if (dataRepresentingSavedArray != nil) {
                    NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
                    if (oldSavedArray != nil){
                        [favoritesArray setArray:oldSavedArray];
                    }
                }
                for (int i=0; i < favoritesArray.count; i++){
                    Event *savedEvent = [favoritesArray objectAtIndex:i];
                    
                    for (int j=0;j < self.events.count;j++){
                        Event *newEvent = [self.events objectAtIndex:j];
                        if (savedEvent.eventID == newEvent.eventID){
                            if (savedEvent.reminderSet){
                                UILocalNotification *reminder = [[UILocalNotification alloc]init];
                                reminder.fireDate = [NSDate dateWithTimeInterval:-900 sinceDate:newEvent.realDate];
                                reminder.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Berlin"];
                                reminder.alertBody = [NSString stringWithFormat:@"Your favorite event %@ will start in 15 minutes",newEvent.title];
                                reminder.alertAction = @"Open";
                                reminder.soundName = @"scifi.caf";
                                reminder.applicationIconBadgeNumber = 1;
                                NSDictionary *userDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:newEvent.eventID] forKey:@"28C3Reminder"];
                                reminder.userInfo = userDict;
                                [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
                                [reminder release];
                            }
                            newEvent.reminderSet = savedEvent.reminderSet;
                            [favoritesArray replaceObjectAtIndex:i withObject:newEvent];
                        }
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:favoritesArray] forKey:@"favorites"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [favoritesArray release];
                 */
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize]; // SAVE STATE
            NSString *updatedReminders = shouldRescheduleAndCheckLocalNotifications ? @" We updated your reminders and favorites." : @"";
            NSString *messageString = [NSString stringWithFormat:@"The Fahrplan was updated to %@.%@", versionUpdated, updatedReminders];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Updated" message:messageString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
        }
                
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_SUCCEEDED object:self];
        
        if( isCachedContent ) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Could not update data. Using last cached data!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
        }
    }
    else{
        if( DEBUG ) NSLog( @"BARFBAG: PARSING FAILED." );
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_FAILED object:self];
    }
    if( DEBUG ) NSLog( @"BARFBAG: COMPLETE. WE GOT %i EVENTS.", [scheduledEvents count] );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_FINISHED object:self];
    parser.parserDelegate = nil;
    xmlParser.delegate = nil;
    [parser release];
    [xmlParser release];
}

- (void) barfBagFetchContentWithUrlString:(NSString*)urlString {
    if( DEBUG ) NSLog( @"BARFBAG: FETCHING FROM %@", urlString );
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:kCONNECTION_TIMEOUT];
    
    [self addUserAgentInfoToRequest:theRequest];
    
    BOOL shouldCheckModifiedDate = NO;
    if( shouldCheckModifiedDate ) {
        NSString *modifiedDateString = nil;
        CGFloat secondsForTwoMonths = 60*24*60*60;
        NSDate *lastModifiedDate = [NSDate dateWithTimeIntervalSinceNow:-secondsForTwoMonths];
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
            df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            modifiedDateString = [df stringFromDate:lastModifiedDate];
            [df release];
        }
        @catch (NSException * e) {
            // do nothing
        }
        NSLog( @"FETCHING STUFF SINCE DATE: %@", lastModifiedDate );
        [theRequest addValue:modifiedDateString forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    // KICK OFF CONNECTION AS BLOCK
    [SinaURLConnection asyncConnectionWithRequest:theRequest completionBlock:^(NSData *data, NSURLResponse *response) {
        if( DEBUG ) NSLog( @"BARFBAG: SERVER STATUSCODE WAS %i", ((NSHTTPURLResponse*)response).statusCode );
        // REPLACE STORED OFFLINE DATA
        BOOL isCached = NO;
        if( data && [data length] > 500 ) {
            isCached = NO;
            // SAVE INFOS
            NSString *pathToStoreFile = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_CACHED_FAHRPLAN]; // CACHE .xml file
            BOOL hasStoredFile = [data writeToFile:pathToStoreFile atomically:YES];
            if( !hasStoredFile ) {
                if( DEBUG ) NSLog( @"BARFBAG: XML SAVING FAILED!!!" );
            }
            else {
                if( DEBUG ) NSLog( @"BARFBAG: XML SAVING SUCCEEDED." );
            }
            [self barfBagFillCached:isCached];
        }
        else {
            isCached = YES;
            [self barfBagFillCached:isCached];
        }
    } errorBlock:^(NSError *error) {
        NSLog( @"error = %@", error );
        // TODO: DISPLAY SOME ERROR...
        BOOL isCached = YES;
        [self barfBagFillCached:isCached];
    } uploadProgressBlock:^(float progress) {
        // do nothing
    } downloadProgressBlock:^(float progress) {
        // TODO: UPDATE PROGRESS DISPLAY ...
    } cancelBlock:^(float progress) {
        // do nothing
    }];
}

- (void) barfBagRefresh {
    [self barfBagFetchContentWithUrlString:kCONNECTION_CONTENT_URL_EN];
}

#pragma mark - Application Transition after Welcome

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

#pragma mark - Application Launching & State Transitions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.themeColor = [self randomColor];
    WelcomeViewController *controller = [[[WelcomeViewController alloc] init] autorelease];
    _window.rootViewController = controller;
    [_window makeKeyAndVisible];
    
    // TRY TO UPDATE DATA IMMEDIATELY
    [self barfBagRefresh];
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
