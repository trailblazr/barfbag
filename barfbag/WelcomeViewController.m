//
//  WelcomeViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"

@implementation WelcomeViewController

@synthesize congressMessagePlainLabel;
@synthesize congressMessageSemiboldLabel;
@synthesize barfBagBrandLabel;

- (void) dealloc {
    self.congressMessagePlainLabel = nil;
    self.congressMessageSemiboldLabel = nil;
    self.barfBagBrandLabel = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void) continueAfterWelcome {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if( finished ) {
            // TRY TO INIT WITH EXISTING DATA
            BOOL shouldAutoUpdateOnStartup = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE defaultValue:YES];
            if( shouldAutoUpdateOnStartup ) {
                [[self appDelegate] allDataRefresh];
            }
            else {
                [[self appDelegate] allDataLoadCached];
            }
            [self.view removeFromSuperview];
        }
    }];
}

- (void) prepareMessage {
    UIColor *textColor = kCOLOR_WHITE;

    CGFloat fontSize40 = [[UIDevice currentDevice] isPad] ? 80.0f : 40.0f;
    
    // congressMessagePlainLabel.alpha = 0.0f;
    // congressMessageSemiboldLabel.alpha = 0.0f;
    // barfBagBrandLabel.alpha = 0.0f;
    
    // PLAIN
    NSMutableString *messagePlain = [NSMutableString string];
    [messagePlain appendString:@"N.O-T/M.Y-D\n"];
    [messagePlain appendString:@"E/PA.R-TM/E\n"];
    [messagePlain appendString:@"N.T-2.9-C/3\n"];
    [messagePlain appendString:@"27.-30.12./\n"];
    [messagePlain appendString:@"HA/M.B-U/RG"];
    congressMessagePlainLabel.font = [UIFont fontWithName:@"SourceCodePro-Light" size:fontSize40];
    congressMessagePlainLabel.text = messagePlain;
    congressMessagePlainLabel.textColor = textColor;

    // SEMIBOLD
    NSMutableString *messageSemibold = [NSMutableString string];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@"    2.9-C/3\n"];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@" "];
    congressMessageSemiboldLabel.font = [UIFont fontWithName:@"SourceCodePro-Semibold" size:fontSize40];
    congressMessageSemiboldLabel.text = messageSemibold;
    congressMessageSemiboldLabel.textColor = textColor;
    
    // BRAND
    barfBagBrandLabel.font = [UIFont fontWithName:@"SourceCodePro-Black" size:fontSize40];
    barfBagBrandLabel.text = @"B/AR.F-BA/G";
    barfBagBrandLabel.textColor = textColor;
}

- (void) displayMessage {
    UIColor *textColor = kCOLOR_WHITE;
    UIColor *backgroundColor = kCOLOR_BACK;
#if SCREENSHOTMODE
    backgroundColor = kCOLOR_BACK;
    textColor = kCOLOR_WHITE;
#else
    backgroundColor = [self themeColor];
    textColor = kCOLOR_BACK;
#endif
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        congressMessagePlainLabel.alpha = 1.0f;
        congressMessageSemiboldLabel.alpha = 1.0f;
        barfBagBrandLabel.alpha = 1.0f;
        
        congressMessagePlainLabel.textColor = textColor;
        congressMessageSemiboldLabel.textColor = textColor;
        barfBagBrandLabel.textColor = textColor;
        self.view.backgroundColor = backgroundColor;
    } completion:^(BOOL finished) {
        if( finished ) {
            [self performSelector:@selector(continueAfterWelcome) withObject:self afterDelay:kSECONDS_DISPLAY_WELCOME];
        }
    }];
}

- (void)viewDidLoad {
   [super viewDidLoad];
    self.view.backgroundColor = kCOLOR_BACK;
    [self prepareMessage];
    [self displayMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
