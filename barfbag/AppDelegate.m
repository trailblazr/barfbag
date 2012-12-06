//
//  AppDelegate.m
//  barfbag
//
//  Created by Lincoln Six Echo on 02.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "AppDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "SinaURLConnection.h"

#import "GenericTabBarController.h"

#import "ScheduleNavigationController.h"
#import "ScheduleSemanticNavigationController.h"
#import "VideoStreamNavigationController.h"
#import "ConfigurationNavigationController.h"

#import "WelcomeViewController.h"

// PENTABARF SCHEDULE OBJECTS
#import "Conference.h"
#import "Day.h"
#import "Event.h"
#import "Link.h"
#import "Person.h"

// SEMANTIC WIKI OBJECTS & CONNECTION HANDLING
#import "JSONWorkshops.h"
#import "JSONAssemblies.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController  = _tabBarController;
@synthesize themeColor = _themeColor;
@synthesize scheduledConferences;
@synthesize semanticWikiAssemblies;
@synthesize semanticWikiWorkshops;
@synthesize hud;

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [_themeColor release];
    self.scheduledConferences = nil;
    self.semanticWikiAssemblies = nil;
    self.semanticWikiWorkshops = nil;
    self.hud = nil;
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

- (void) alertWithTag:(NSInteger)tag title:(NSString*)title andMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void) configureAppearance {
    if( ![[UINavigationBar class] respondsToSelector:@selector(appearance)] ) return;

    // MPAVController
    // MPAVController *proxyMpavController = [MPAVController appearance];
    
}

#pragma mark - BarfBagParserDelegate

- (void) barfBagParser:(BarfBagParser*)parser parsedConferences:(NSArray *)conferencesArray {
    self.scheduledConferences = conferencesArray;

    // CHECK IF WE HAVE VALID DATA
    if( !scheduledConferences || [scheduledConferences count] == 0 ) {
        if( DEBUG ) NSLog( @"BARFBAG: PARSING FAILED (NO DATA FOUND!)" );
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_FAILED object:self];
        return;
    }
    
    // UPDATE VERSION & INFORM USER IF NECESSARY
    Conference *currentConference = nil;
    @try {
        currentConference = (Conference*)[scheduledConferences lastObject];
    }
    @catch (NSException *exception) {
        // do nothing
    }
    if( currentConference ) {
        NSString *versionCurrent = [self barfBagCurrentDataVersion];
        NSString *versionUpdated = currentConference.release;
        [[NSUserDefaults standardUserDefaults] setObject:versionUpdated forKey:kUSERDEFAULT_KEY_DATA_VERSION_UPDATED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL shouldDumpObjectGraph = NO; // FOR DEBUGGING PROBLEMS
        if( shouldDumpObjectGraph ) {
             NSLog( @"CREATED CONFERENCE: %@", currentConference );
             NSLog( @"CREATED %i DAYS", [currentConference.days count] );
             for( Day *currentDay in currentConference.days ) {
                 NSLog( @"\n\nDAY %i HAS %i EVENTS\n", currentDay.dayIndex, [currentDay.events count] );
                 for( Event *currentEvent in currentDay.events ) {
                     //NSLog( @"EVENT (%i): %@ [TIME: %i:%i]", currentEvent.eventId, currentEvent.title, currentEvent.timeHour, currentEvent.timeMinute );
                     NSLog( @"%@", currentEvent );
                 }
             }
        }

        BOOL hasNewDataVersion = ![versionUpdated isEqualToString:versionCurrent];
        if( hasNewDataVersion ) {
            [[NSUserDefaults standardUserDefaults] setObject:versionUpdated forKey:kUSERDEFAULT_KEY_DATA_VERSION_CURRENT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self alertWithTag:0 title:LOC( @"Aktualisierung" ) andMessage:[NSString stringWithFormat:LOC( @"Die Plandaten wurden aktualisiert auf %@." ), versionUpdated]];
        }
    }
    if( DEBUG ) NSLog( @"BARFBAG: PARSING COMPLETED." );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_COMPLETED object:self];
    
    [self semanticWikiRefresh];
}

#pragma mark - Fetching, Caching & Parsing of XML (semantic wiki)

- (BOOL) semanticWikiFetchAssemblies {
    [self showHudWithCaption:LOC( @"Aktualisiere Assemblies" ) hasActivity:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_STARTED object:self];
    NSURL *connectionUrl = [NSURL URLWithString:kURL_JSON_ASSEMBLIES];
    BBJSONConnectOperation *operation = [BBJSONConnectOperation operationWithConnectUrl:connectionUrl andPathComponent:nil delegate:self selFail:@selector(operationFailedAssemblies:) selInvalid:@selector(operationInvalidAssemblies:) selSuccess:@selector(operationSuccessAssemblies:)];
    operation.jsonObjectClass = [JSONAssemblies class];
    operation.jsonMappingDictionary = [JSONAssemblies objectMapping];
    operation.isOperationDebugEnabled = NO;
    // [self operationAddAsPending:operation];
    [[BBJSONConnector instance] operationInitiate:operation];
    return YES;
}

- (void) operationSuccessAssemblies:(BBJSONConnectOperation*)operation {
    if( DEBUG ) NSLog( @"%s: SUCCESS.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_SUCCEEDED object:self];
    // [self operationRemoveFromPending:operation];
    JSONAssemblies *assemblies = (JSONAssemblies*)operation.result;
    self.semanticWikiAssemblies = [assemblies assemblyItems];
    if( DEBUG ) NSLog( @"ASSEMBLIES FOUND: %i items", [semanticWikiAssemblies count] );
    // if( DEBUG ) NSLog( @"ASSEMBLIES: %@", assemblies );
    [self semanticWikiFetchWorkshops];
}

- (void) operationFailedAssemblies:(BBJSONConnectOperation*)operation {
    // [self operationRemoveFromPending:operation];
    if( DEBUG ) NSLog( @"%s: FAIL.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_FAILED object:self];
    [self hideHud];
}

- (void) operationInvalidAssemblies:(BBJSONConnectOperation*)operation {
    // [self operationRemoveFromPending:operation];
    if( DEBUG ) NSLog( @"%s: INVALID.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [self hideHud];
}


- (BOOL) semanticWikiFetchWorkshops {
    [self showHudWithCaption:LOC( @"Aktualisiere Workshops" ) hasActivity:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_STARTED object:self];
    NSURL *connectionUrl = [NSURL URLWithString:kURL_JSON_WORKSHOPS];
    BBJSONConnectOperation *operation = [BBJSONConnectOperation operationWithConnectUrl:connectionUrl andPathComponent:nil delegate:self selFail:@selector(operationFailedWorkshops:) selInvalid:@selector(operationInvalidWorkshops:) selSuccess:@selector(operationSuccessWorkshops:)];
    operation.jsonObjectClass = [JSONWorkshops class];
    operation.jsonMappingDictionary = [JSONWorkshops objectMapping];
    operation.isOperationDebugEnabled = NO;
    // [self operationAddAsPending:operation];
    [[BBJSONConnector instance] operationInitiate:operation];
    return YES;
}

- (void) operationSuccessWorkshops:(BBJSONConnectOperation*)operation {
    if( DEBUG ) NSLog( @"%s: SUCCESS.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_SUCCEEDED object:self];
    // [self operationRemoveFromPending:operation];
    JSONWorkshops *workshops = (JSONWorkshops*)operation.result;
    self.semanticWikiWorkshops = [workshops workshopItems];
    if( DEBUG ) NSLog( @"WORKSHOPS FOUND: %i items", [semanticWikiWorkshops count] );
    // if( DEBUG ) NSLog( @"WORKSHOPS: %@", workshops );
    [self hideHud];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_COMPLETED object:self]; // MARKS END OF FETCHING
}

- (void) operationFailedWorkshops:(BBJSONConnectOperation*)operation {
    // [self operationRemoveFromPending:operation];
    if( DEBUG ) NSLog( @"%s: FAIL.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_JSON_FAILED object:self];
    [self hideHud];
}

- (void) operationInvalidWorkshops:(BBJSONConnectOperation*)operation {
    // [self operationRemoveFromPending:operation];
    if( DEBUG ) NSLog( @"%s: INVALID.\nOPERATION: %@", __PRETTY_FUNCTION__, operation );
    [self hideHud];
}


- (void) semanticWikiFetchAllData {
    if( DEBUG ) NSLog( @"WIKI: FETCHING DATA..." );
    [self semanticWikiFetchAssemblies];
}

- (void) semanticWikiRefresh {
    [self semanticWikiFetchAllData];
}

#pragma mark - Fetching, Caching & Parsing of XML (pentabarf data)

- (NSString*) barfBagCurrentDataVersion {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUSERDEFAULT_KEY_DATA_VERSION_CURRENT];
}

-(void) barfBagFillCached:(BOOL)isCachedContent {
    NSString *pathToStoredFile = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_CACHED_FAHRPLAN]; // CACHE .xml file
	BarfBagParser *pentaParser = [[BarfBagParser alloc] init];
	pentaParser.responseData = [NSData dataWithContentsOfFile:pathToStoredFile];
	pentaParser.delegate = self;
	[pentaParser startParsingResponseData];
}

- (void) barfBagFetchContentWithUrlString:(NSString*)urlString {
    if( DEBUG ) NSLog( @"BARFBAG: XML FETCHING FROM %@", urlString );
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
        if( DEBUG ) NSLog( @"BARFBAG: XML CONNECTION RESPONSECODE: %i", ((NSHTTPURLResponse*)response).statusCode );
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
        [self hideHud];
    } errorBlock:^(NSError *error) {
        if( DEBUG ) NSLog( @"BARFBAG: NO INTERNET CONNECTION." );
        [self alertWithTag:0 title:LOC( @"Verbindungsproblem" ) andMessage:[NSString stringWithFormat:LOC( @"Derzeit besteht scheinbar\nkeine Internetverbindung zum\nAktualisieren der Daten.\n\nSie verwenden derzeit\n%@ der Daten." ), [self barfBagCurrentDataVersion]]];
        // TODO: DISPLAY SOME ERROR...
        BOOL isCached = YES;
        [self barfBagFillCached:isCached];
        [self hideHud];
    } uploadProgressBlock:^(float progress) {
        // do nothing
    } downloadProgressBlock:^(float progress) {
        // TODO: UPDATE PROGRESS DISPLAY ...
    } cancelBlock:^(float progress) {
        // do nothing
        [self hideHud];
    }];
}

- (void) barfBagRefresh {
    [self showHudWithCaption:LOC( @"Aktualisiere Fahrplan" ) hasActivity:YES];
    [self barfBagFetchContentWithUrlString:kCONNECTION_CONTENT_URL_EN];
}

- (void) barfBargLoadCached {
    NSString *pathToCachedFile = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_CACHED_FAHRPLAN]; // CACHE .xml file
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:pathToCachedFile] ) {
        if( DEBUG ) NSLog( @"BARFBAG: XML LOADING CACHED..." );
        [self barfBagFillCached:YES];
    }
    else {
        // TRY TO UPDATE DATA IMMEDIATELY
        [self barfBagRefresh];
    }
}

#pragma mark - Application Launching & State Transitions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.themeColor = [self randomColor];
    
    // CONFIGURE CUSTOM UI APPEARANCE
    [self configureAppearance];
    
    // SETUP ROOT CONTROLLER
    NSMutableArray *viewControllers = [NSMutableArray array];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [viewControllers addObject:[[[ScheduleNavigationController alloc] initWithNibName:@"ScheduleNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[ScheduleSemanticNavigationController alloc] initWithNibName:@"ScheduleSemanticNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[VideoStreamNavigationController alloc] initWithNibName:@"VideoStreamNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[ConfigurationNavigationController alloc] initWithNibName:@"ConfigurationNavigationController" bundle:nil] autorelease]];
    }
    else {
        [viewControllers addObject:[[[ScheduleNavigationController alloc] initWithNibName:@"ScheduleNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[ScheduleSemanticNavigationController alloc] initWithNibName:@"ScheduleSemanticNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[VideoStreamNavigationController alloc] initWithNibName:@"VideoStreamNavigationController" bundle:nil] autorelease]];
        [viewControllers addObject:[[[ConfigurationNavigationController alloc] initWithNibName:@"ConfigurationNavigationController" bundle:nil] autorelease]];
    }
    self.tabBarController = [[[GenericTabBarController alloc] init] autorelease];
    _tabBarController.viewControllers = viewControllers;
    _window.rootViewController = self.tabBarController;
    [_window makeKeyAndVisible];
    
    // ADD WELCOME CONTROLLER ON TOP
    WelcomeViewController *controller = [[[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil] autorelease];
    CGFloat width = _window.bounds.size.width;
    CGFloat height = _window.bounds.size.height;
    CGRect windowRect = CGRectMake(0.0, 0.0, width, height);
    controller.view.frame = windowRect;
    [_window.rootViewController.view addSubview:controller.view];
        
    // TRY TO INIT WITH EXISTING DATA WHILE WELCOME IS PRESENTED
    [self   barfBargLoadCached    ];
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

#pragma mark - Headup Display Management

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity {
    // ADD HUD VIEW
    if( !hud ) {
        self.hud = [[ATMHud alloc] initWithDelegate:self];
        [_window.rootViewController.view addSubview:hud.view];
    }
    [hud setCaption:caption];
    [hud setActivity:hasActivity];
    [hud show];
}

- (void) hideHud {
    [hud hide];
}

- (void) userDidTapHud:(ATMHud *)_hud {
	[_hud hide];
}


@end
