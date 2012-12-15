//
//  WebbrowserViewController.h
//  Nautical
//
//  Created by Helge Städtler on 10.01.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "GenericViewController.h"

@protocol WebbrowserViewControllerDelegate;

@interface WebbrowserViewController : GenericViewController <UIWebViewDelegate,UIActionSheetDelegate> {

	IBOutlet UIWebView* fullWebView;
	IBOutlet UIBarButtonItem* backButton;
	IBOutlet UIBarButtonItem* forwardButton;
	IBOutlet UIBarButtonItem* stopReloadButton;
	IBOutlet UIToolbar* myToolBar;
	IBOutlet UINavigationBar* myNavBar;
	IBOutlet UINavigationItem* myNavItem;
	IBOutlet UIActivityIndicatorView* loadingIndicator;
	IBOutlet UIImageView *noDataImageView;
	BOOL shouldScaleToFit;
    BOOL isDisplayingNice404;
    BOOL isRequestCheckDone;
    BOOL shouldDetectPages404;
    BOOL shouldStartLoadingCheckedRequest;
    BOOL shouldAddDoneButton;
    BOOL shouldAddActionButton;
    BOOL shouldUseSmoothFading;
    BOOL isPresentedModal;
	NSURL *urlToOpen;
    NSURLRequest *requestToCheck;
    NSURLRequest *requestChecked;
    NSTimer *timerActivityIndicator;
    NSTimer *timerFadeInFinal;
    id<WebbrowserViewControllerDelegate> delegate;
}

@property (nonatomic, assign) BOOL shouldScaleToFit;
@property (nonatomic, assign) BOOL isDisplayingNice404;
@property (nonatomic, assign) BOOL isRequestCheckDone;
@property (nonatomic, assign) BOOL shouldDetectPages404;
@property (nonatomic, assign) BOOL shouldStartLoadingCheckedRequest;
@property (nonatomic, assign) BOOL shouldAddDoneButton;
@property (nonatomic, assign) BOOL shouldAddActionButton;
@property (nonatomic, assign) BOOL shouldUseSmoothFading;
@property (nonatomic, assign) BOOL isPresentedModal;
@property (nonatomic, assign) id<WebbrowserViewControllerDelegate> delegate;
@property (nonatomic, retain) UIWebView* fullWebView;
@property (nonatomic, retain) NSURL *urlToOpen;
@property (nonatomic, retain) UIBarButtonItem* backButton;
@property (nonatomic, retain) UIBarButtonItem* forwardButton;
@property (nonatomic, retain) UIBarButtonItem* stopReloadButton;
@property (nonatomic, retain) UIToolbar* myToolBar;
@property (nonatomic, retain) UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, retain) UINavigationBar* myNavBar;
@property (nonatomic, retain) UINavigationItem* myNavItem;
@property (nonatomic, retain) UIImageView *noDataImageView;
@property (nonatomic, retain) NSURLRequest *requestToCheck;
@property (nonatomic, retain) NSURLRequest *requestChecked;
@property (nonatomic, retain) NSTimer *timerActivityIndicator;
@property (nonatomic, retain) NSTimer *timerFadeInFinal;

- (IBAction) actionStopReload:(id)sender;
- (IBAction) actionDone:(id)sender;
- (IBAction) actionAskForAction;

- (void) addActionButtonToNavigationItem:(UINavigationItem*)navigationItemToAddTo animated:(BOOL)animated;

- (void) cancelPendingRequestsBeforeExit;
- (void) switchToReload;
- (void) switchToStop;

// UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView;
- (void) webViewDidStartLoad:(UIWebView *)webView;
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@protocol WebbrowserViewControllerDelegate <NSObject>

- (void) webcontentViewControllerDidFinish:(WebbrowserViewController*)controller;

@end
