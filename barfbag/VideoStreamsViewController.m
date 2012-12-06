//
//  VideoStreamsViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "VideoStreamsViewController.h"

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

- (void) actionRefreshStreamHtml {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [videoStreamsWebView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"streams" withExtension:@"html"]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = LOC( @"Videostreams" );
    self.view.backgroundColor = [self themeColor];
    videoStreamsWebView.opaque = NO;
    videoStreamsWebView.backgroundColor = kCOLOR_CLEAR;
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshStreamHtml)] autorelease];
    self.navigationItem.rightBarButtonItem = item;    
    [self actionRefreshStreamHtml];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self hideActivityIndicator];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self showActivityIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideActivityIndicator];
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
}

@end
