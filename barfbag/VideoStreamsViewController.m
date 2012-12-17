//
//  VideoStreamsViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "VideoStreamsViewController.h"
#import "AppDelegate.h"

@implementation VideoStreamsViewController

@synthesize videoStreamsWebView;


- (void) dealloc {
    self.videoStreamsWebView = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - User Actions

#pragma mark - User Actions

- (void) actionRefreshData {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // [[self appDelegate] videoStreamsRefresh];
}

- (void) actionUpdateDisplayAfterRefresh {
    [self actionRefreshStreamHtml];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;
}

- (void) actionRefreshStreamHtml {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;
    NSString *cachedRemoteHtml = [self appDelegate].videoStreamsHtml;
    if( cachedRemoteHtml && [cachedRemoteHtml length] > 0 ) {
        videoStreamsWebView.scalesPageToFit = NO;
        [videoStreamsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [videoStreamsWebView loadHTMLString:cachedRemoteHtml baseURL:nil];
    }
    else {
        [videoStreamsWebView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"streams_en" withExtension:@"html"]]];
    }
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_STREAM_COMPLETED  object:nil];
    [super viewDidLoad];
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshData)] autorelease];
    self.navigationItem.rightBarButtonItem = item;

    UIBarButtonItem *itemBack = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left_white.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionRefreshStreamHtml)] autorelease];
    self.navigationItem.leftBarButtonItem = itemBack;
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;

    self.navigationItem.title = LOC( @"29C3 Livestreams" );
    videoStreamsWebView.opaque = NO;
    videoStreamsWebView.backgroundColor = kCOLOR_CLEAR;
    [self actionRefreshStreamHtml];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    webView.scalesPageToFit = ( navigationType == UIWebViewNavigationTypeLinkClicked );
    NSLog( @"WILL SCALE TO FIT: %@", webView.scalesPageToFit ? @"YES" : @"NO" );
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;
    [self hideActivityIndicator];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self showActivityIndicator];
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.navigationItem.leftBarButtonItem.enabled = videoStreamsWebView.canGoBack;
    BOOL shouldShowAlert = NO;
    NSString *errorString = nil;
    if( error ) {
        NSInteger errorCode = [error code];
        if( errorCode != 204 ) { // KNOWN ERRORS WHICH ARE NONE
            shouldShowAlert = YES;
        }
        errorString = [NSString stringWithFormat:@"\n\n%@", error];
    }
    else {
        errorString = @"";
    }
    if( shouldShowAlert ) {
        NSString *message = [NSString stringWithFormat:LOC( @"Videostreams konnten nicht erfolgreich geladen werden. %@" ), errorString];
        [self alertWithTag:0 title:LOC( @"Problem" ) andMessage:message];
    }
    [self hideActivityIndicator];
}

@end
