//
//  WelcomeViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "WelcomeViewController.h"

@implementation WelcomeViewController

@synthesize congressMessagePlainLabel;
@synthesize congressMessageSemiboldLabel;

- (void) dealloc {
    self.congressMessagePlainLabel = nil;
    self.congressMessageSemiboldLabel = nil;
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
        congressMessagePlainLabel.alpha = 0.0f;
        congressMessageSemiboldLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if( finished ) {
            [[UIApplication sharedApplication].delegate performSelector:@selector(continueAfterWelcome)];        
        }
    }];
}

- (void) prepareMessage {
    congressMessagePlainLabel.alpha = 0.0f;
    congressMessageSemiboldLabel.alpha = 0.0f;
    
    // PLAIN
    NSMutableString *messagePlain = [NSMutableString string];
    [messagePlain appendString:@"N.O-T/M.Y-D\n"];
    [messagePlain appendString:@"E/PA.R-TM/E\n"];
    [messagePlain appendString:@"N.T-2.9-C/3\n"];
    [messagePlain appendString:@"27.-30.12./\n"];
    [messagePlain appendString:@"HA/M.B-U/RG"];
    congressMessagePlainLabel.font = [UIFont fontWithName:@"SourceCodePro-Light" size:40.0];
    congressMessagePlainLabel.text = messagePlain;
    congressMessagePlainLabel.textColor = kCOLOR_BACK;

    // SEMIBOLD
    NSMutableString *messageSemibold = [NSMutableString string];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@"    2.9-C/3\n"];
    [messageSemibold appendString:@" \n"];
    [messageSemibold appendString:@" "];
    congressMessageSemiboldLabel.font = [UIFont fontWithName:@"SourceCodePro-Semibold" size:40.0];
    congressMessageSemiboldLabel.text = messageSemibold;
    congressMessageSemiboldLabel.textColor = kCOLOR_BACK;
}

- (void) displayMessage {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        congressMessagePlainLabel.alpha = 1.0f;
        congressMessageSemiboldLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if( finished ) {
            [self performSelector:@selector(continueAfterWelcome) withObject:self afterDelay:1.5];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self themeColor];
    [self prepareMessage];
    [self displayMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
