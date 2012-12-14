//
//  WebbrowserViewController.m
//  Nautical
//
//  Created by Helge Städtler on 10.01.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "WebbrowserViewController.h"
#import <MobileCoreServices/MobileCoreServices.h> // UIPasteboard stuff
#import "SinaURLConnection.h"

#define kSTRING_DEFAULT_LOADING     @"Laden..."
#define kSTRING_DEFAULT_WAIT        @"Warten..."
#define kSTRING_DEFAULT_ERROR       @"Fehler"
#define kSTRING_DEFAULT_DONE        @"Webseite"
#define kSTRING_DEFAULT_FAIL_404    @"Fehler 404"

@implementation WebbrowserViewController

@synthesize fullWebView;
@synthesize myToolBar;
@synthesize backButton;
@synthesize forwardButton;
@synthesize stopReloadButton;
@synthesize shouldScaleToFit;
@synthesize urlToOpen;
@synthesize loadingIndicator;
@synthesize delegate;
@synthesize myNavItem;
@synthesize myNavBar;
@synthesize isDisplayingNice404;
@synthesize noDataImageView;
@synthesize shouldDetectPages404;
@synthesize requestChecked;
@synthesize requestToCheck;
@synthesize shouldStartLoadingCheckedRequest;
@synthesize isRequestCheckDone;
@synthesize timerActivityIndicator;
@synthesize shouldAddDoneButton;
@synthesize shouldAddActionButton;

BOOL isFirstLoad = YES;
BOOL isShowingActionSheet = NO;

#pragma mark -
#pragma mark destruction

- (void)dealloc {
    self.delegate = nil;
    if( timerActivityIndicator && [timerActivityIndicator isValid] ) {
        [timerActivityIndicator invalidate];
    }
    self.timerActivityIndicator = nil;
    [fullWebView release];
    [myToolBar release];
    [backButton release];
    [forwardButton release];
    [stopReloadButton release];
    [urlToOpen release];
    [loadingIndicator release];
    self.myNavItem = nil;
    self.myNavBar = nil;
    self.noDataImageView = nil;
    self.requestChecked = nil;
    self.requestToCheck =nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void) shouldShowNetworkIndicator {
    
}

- (void) shouldHideNetworkIndicator {
    
}

#pragma mark - Activity Timer Handling

- (void) resetTimerForFadeOutActivityIndicator {
    if( timerActivityIndicator && [timerActivityIndicator isValid] ) {
        [timerActivityIndicator invalidate];
    }
    self.timerActivityIndicator = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(fadeOutActivityIndicator) userInfo:nil repeats:NO];
}

- (void) fadeInActivityIndicator {
    if( !loadingIndicator.isAnimating ) {
        [loadingIndicator startAnimating];    
        loadingIndicator.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            loadingIndicator.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self switchToStop];
            [self resetTimerForFadeOutActivityIndicator];
        }];
    }
    else {
        [self resetTimerForFadeOutActivityIndicator];    
    }
}

- (void) fadeOutActivityIndicator {
    loadingIndicator.alpha = 1.0;
    [UIView animateWithDuration:0.5 animations:^{
        loadingIndicator.alpha = 0.0;
    } completion:^(BOOL finished) {
        loadingIndicator.alpha = 0.0;
        [loadingIndicator stopAnimating];
        [self switchToReload];
    }];
}

#pragma mark - construction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.shouldScaleToFit = YES;
        self.isDisplayingNice404 = YES;
        self.shouldDetectPages404 = YES;
        self.isRequestCheckDone = NO;
        self.shouldAddDoneButton = YES;
        self.shouldAddActionButton = YES;
    }
    return self;
}

- (void) addUserAgentInfoToRequest:(NSMutableURLRequest*)request {
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appPlatform = [[UIDevice currentDevice] platformString];
	NSString *appSystemVersion = [[UIDevice currentDevice] systemVersion];
	NSString *appLanguageContext = [[NSLocale currentLocale] localeIdentifier];
	
	NSString *uaString = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; %@)", appName, appVersion, appPlatform, appSystemVersion, appLanguageContext];
	if( DEBUG ) NSLog( @"USER AGENT: %@", uaString );
	[request setValue:uaString forHTTPHeaderField:@"User-Agent"];
}

- (void) actionFadeInWebView {
    if( fullWebView.alpha != 0.0f ) return;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fullWebView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // do nothing
    }];    
}

- (void) addActionButtonToNavigationItem:(UINavigationItem*)navigationItemToAddTo animated:(BOOL)animated {
    if( !navigationItemToAddTo ) return;
    UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionAskForAction)] autorelease];
    [navigationItemToAddTo setRightBarButtonItem:actionButton animated:animated];
}

- (void) addDoneButtonToNavigationItem:(UINavigationItem*)navigationItemToAddTo animated:(BOOL)animated {
    if( !navigationItemToAddTo ) return;
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)] autorelease];
    [navigationItemToAddTo setLeftBarButtonItem:doneButton animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    myNavItem.title = kSTRING_DEFAULT_LOADING;
    loadingIndicator.alpha = 0.0f;
    if( shouldAddDoneButton ) {
        [self addDoneButtonToNavigationItem:myNavItem animated:NO];
    }
    if( shouldAddActionButton ) {
        [self addActionButtonToNavigationItem:myNavItem animated:NO];
    }

    fullWebView.alpha = 0.0;
   [myToolBar setTintColor:kCOLOR_BACK];
	[fullWebView setScalesPageToFit:shouldScaleToFit];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlToOpen cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:30];
    self.isRequestCheckDone = NO;    
    self.requestChecked = nil;
    [self addUserAgentInfoToRequest:request];
    self.requestToCheck = request;
	[fullWebView loadRequest:request];
    [myNavBar setTintColor:kCOLOR_BACK];
    /*
    NSMutableDictionary *titleTextAttributesDict = [NSMutableDictionary dictionary];
    [titleTextAttributesDict setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [titleTextAttributesDict setObject:[UIFont fontWithName:@"Cabin-Bold" size:24.0] forKey:UITextAttributeFont];
    myNavBar.titleTextAttributes = titleTextAttributesDict;
     */
    noDataImageView.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch ( actionSheet.tag ) {
        case kACTIONSHEET_WEBVIEW_ASK_ACTION:
            if( buttonIndex == actionSheet.firstOtherButtonIndex ) {
                [UIPasteboard generalPasteboard].string = [urlToOpen absoluteString];
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex+1 ) {
                [[UIApplication sharedApplication] openURL:urlToOpen];
            }
            break;
            
        default:
            break;
    }
    isShowingActionSheet = NO;
}

#pragma mark - user interaction

- (void) cancelPendingRequestsBeforeExit {
    fullWebView.delegate = nil;
    [fullWebView stopLoading];
}

- (IBAction) actionStopReload:(id)sender {
    if( fullWebView.isLoading ) {
        [fullWebView stopLoading];
    }
    else {
        [fullWebView reload];
    }
}

- (IBAction) actionDone:(id)sender {
    [self cancelPendingRequestsBeforeExit];
    if( delegate && [delegate respondsToSelector:@selector(webcontentViewControllerDidFinish:)] ) {
        [delegate webcontentViewControllerDidFinish:self];
    }
    else { // REMOVE INELEGANTLY
        [self.view.superview removeFromSuperview];
    }
}

// TODO: exchange standard actionsheet with block actionsheet
/*
 BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title" message:@"This is a very long message, designed just to show you how smart this class is"];
 
 [alert setCancelButtonWithTitle:@"Cancel" block:nil];
 [alert setDestructiveButtonWithTitle:@"Kill!" block:nil];
 [alert addButtonWithTitle:@"Show Action Sheet on top" block:^{
 [self showActionSheet:nil];
 }];
 [alert addButtonWithTitle:@"Show another alert" block:^{
 [self showAlert:nil];
 }];
 [alert show];
 */

- (IBAction) actionAskForAction {
    if( isShowingActionSheet ) return;
    NSString *shortUrl = [urlToOpen absoluteString];
    if( [shortUrl length] > 40 ) {
        shortUrl = [shortUrl substringToIndex:40];
        shortUrl = [shortUrl stringByAppendingString:@" […]"];
    }
    NSString *sheetTitle = [NSString stringWithFormat:@"%@\n%@",myNavItem.title, shortUrl ];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:LOC(@"Abbrechen") destructiveButtonTitle:nil otherButtonTitles:LOC(@"URL kopieren"),LOC(@"Öffnen in Safari"), nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    sheet.tag = kACTIONSHEET_WEBVIEW_ASK_ACTION;
    isShowingActionSheet = YES;
    
    if( [sheet respondsToSelector:@selector(showFromBarButtonItem:)] ) {
        [sheet showFromBarButtonItem:myNavItem.rightBarButtonItem animated:YES];
    }
    else {
        [sheet showInView:self.view];
    }
    [sheet release];
}

#pragma mark - webview management

- (void) switchToReload {
    NSArray *toobarItems = myToolBar.items;
    NSMutableArray *itemsFresh = [NSMutableArray array];
    for( UIBarButtonItem *currentItem in toobarItems ) {
        if( currentItem != stopReloadButton ) {
            [itemsFresh addObject:currentItem];
        }
        else {
            self.stopReloadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:fullWebView action:@selector(reload)] autorelease];
            [itemsFresh addObject:stopReloadButton];
        }
    }
    [myToolBar setItems:itemsFresh animated:YES];
}

- (void) switchToStop {
    NSArray *toobarItems = myToolBar.items;
    NSMutableArray *itemsFresh = [NSMutableArray array];
    for( UIBarButtonItem *currentItem in toobarItems ) {
        if( currentItem != stopReloadButton ) {
            [itemsFresh addObject:currentItem];
        }
        else {
            self.stopReloadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:fullWebView action:@selector(stopLoading)] autorelease];
            [itemsFresh addObject:stopReloadButton];
        }
    }
    [myToolBar setItems:itemsFresh animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self shouldHideNetworkIndicator];
	[backButton setEnabled:[webView canGoBack]];
	[forwardButton setEnabled:[webView canGoForward]];
    if( fullWebView.alpha == 0.0f ) {
        [self actionFadeInWebView];
    }
    if( !isFirstLoad ) {
        NSString *documentTitle = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSString *documentBaseUrl = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.URL"];
        if( documentBaseUrl && [documentBaseUrl length] > 0 ) {
            self.urlToOpen = [NSURL URLWithString:documentBaseUrl];
        }
        // NSString *htmlInBody = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        if( documentTitle && [documentTitle length] > 0 ) {
            myNavItem.title = documentTitle;
        }
        else {
            myNavItem.title = kSTRING_DEFAULT_DONE;
        }
    }
    else {
        NSString *documentTitle = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSString *documentBaseUrl = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.URL"];
        if( documentBaseUrl && [documentBaseUrl length] > 0 ) {
            self.urlToOpen = [NSURL URLWithString:documentBaseUrl];
        }
        // NSString *htmlInBody = [fullWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        if( documentTitle && [documentTitle length] > 0 ) {
            myNavItem.title = documentTitle;
        }
        else {
            myNavItem.title = kSTRING_DEFAULT_DONE;        
        }
        isFirstLoad = NO;
    }
}

- (void) showNice404 {
    myNavItem.title = kSTRING_DEFAULT_FAIL_404;
    noDataImageView.alpha = 0.0f;
    noDataImageView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        noDataImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.isDisplayingNice404 = YES;
    }];
}

- (void) hideNice404 {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        noDataImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        noDataImageView.hidden = YES;
        self.isDisplayingNice404 = NO;
        myNavItem.title = kSTRING_DEFAULT_LOADING;
    }];
}

- (void) continueStartLoadingRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if( !shouldStartLoadingCheckedRequest ) {
        NSLog( @"SHOWING 404 FOR FAILED URL %@", [request.URL absoluteString] );
        [self showNice404];
    }
    else {
        NSLog( @"INIT REQUEST AGAIN AFTER PRECHECK %@", [request.URL absoluteString] );
        [fullWebView loadRequest:request];
    }
}

- (NSString*) stringStrippedByTrailingSlash:(NSString*)stringToClean {
    if( !stringToClean ) return stringToClean;
    while( stringToClean && ( [stringToClean length] > 0 ) && [[stringToClean substringFromIndex:[stringToClean length]-1] isEqualToString:@"/"] ) {
        stringToClean = [stringToClean substringToIndex:[stringToClean length]-1];
    }
    return stringToClean;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // PRE CHECK DEDICATED REQUESTS WITH PREFLIGHT BEFORE LOADING
    if( isRequestCheckDone ) {
        shouldDetectPages404 = NO;
    }
    /*
    NSLog( @"       request.URL: %@", request.URL ? [request.URL absoluteURL] : @"NO" );
    NSLog( @"requestToCheck.URL: %@", requestToCheck.URL ? [requestToCheck.URL absoluteURL] : @"NO" );
    NSLog( @"requestChecked.URL: %@", requestChecked.URL ? [requestChecked.URL absoluteURL] : @"NO" );
     */
    NSString *cleanRequestURL = [self stringStrippedByTrailingSlash:[request.URL absoluteString]];
    NSString *cleanRequestToCheck = [self stringStrippedByTrailingSlash:[requestToCheck.URL absoluteString]];
    NSString *cleanRequestChecked = [self stringStrippedByTrailingSlash:[requestChecked.URL absoluteString]];
    BOOL isRequestEqualToRequestToCheck = [cleanRequestURL isEqualToString:cleanRequestToCheck];
    BOOL isRequestEqualToRequestChecked = [cleanRequestURL isEqualToString:cleanRequestChecked];
    /*
    NSLog( @"       request.URL: %@", cleanRequestURL ? cleanRequestURL : @"NO" );
    NSLog( @"requestToCheck.URL: %@", cleanRequestToCheck ? cleanRequestToCheck : @"NO" );
    NSLog( @"requestChecked.URL: %@", cleanRequestChecked ? cleanRequestChecked : @"NO" );
     */
    if( shouldDetectPages404 && ( isRequestEqualToRequestToCheck && !isRequestEqualToRequestChecked ) ) {
        NSLog( @"PRECHECKING URL %@", [request.URL absoluteString] );
        self.shouldStartLoadingCheckedRequest = NO;
        self.requestChecked = request;
        [SinaURLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response) {
            NSInteger httpStatusCode = ((NSHTTPURLResponse*)response).statusCode;
            NSLog( @"HTTP STATUS: %i", httpStatusCode );
            if( httpStatusCode < 400 ) {
                self.isRequestCheckDone = YES;            
                [self performSelector:@selector(actionFadeInWebView) withObject:nil afterDelay:3.5];
                [self hideNice404];
                self.urlToOpen = request.URL;
                NSLog( @"PRECHECK LOADING URL %@", [request.URL absoluteString] );
                self.shouldStartLoadingCheckedRequest = YES;
                [self continueStartLoadingRequest:requestChecked navigationType:navigationType];
            }
            else {
                NSLog( @"ABORTING LOADING OF URL %@", [request.URL absoluteString] );
                self.shouldStartLoadingCheckedRequest = NO;
                [self continueStartLoadingRequest:requestChecked navigationType:navigationType];
            }

      } errorBlock:^(NSError *error) {
          self.isRequestCheckDone = YES;          
          self.shouldStartLoadingCheckedRequest = NO;
          [self continueStartLoadingRequest:requestChecked navigationType:navigationType];
          
      } uploadProgressBlock:^(float progress) {
          // do nothing
      } downloadProgressBlock:^(float progress) {
          // TODO: UPDATE PROGRESS DISPLAY ...
      } cancelBlock:^(float progress) {
          // do nothing
      }];
    return NO;
    }
    else {
        NSLog( @"FINALLY LOADING URL %@", [request.URL absoluteString] );
        self.shouldStartLoadingCheckedRequest = NO;
        self.requestChecked = nil;
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // myNavItem.title = kSTRING_DEFAULT_WAIT;
    [self fadeInActivityIndicator];
	[backButton setEnabled:[webView canGoBack]];
	[forwardButton setEnabled:[webView canGoForward]];
    [self shouldShowNetworkIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // myNavItem.title = kSTRING_DEFAULT_ERROR;
	NSLog( @"WEB URL LOADING ERROR: %@", error );
	[backButton setEnabled:[webView canGoBack]];
	[forwardButton setEnabled:[webView canGoForward]];
    [self shouldHideNetworkIndicator];
}

@end