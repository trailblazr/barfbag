//
//  WelcomeViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "WelcomeViewController.h"

@implementation WelcomeViewController

@synthesize congressMessageLabel;

- (void) dealloc {
    self.congressMessageLabel = nil;
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
        congressMessageLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if( finished ) {
            [[UIApplication sharedApplication].delegate performSelector:@selector(continueAfterWelcome)];        
        }
    }];
}

- (void) prepareMessage {
    congressMessageLabel.alpha = 0.0f;
    NSMutableString *message = [NSMutableString string];
    [message appendString:@"N.O-T/M.Y-D\n"];
    [message appendString:@"E/PA.R-TM/E\n"];
    [message appendString:@"N.T-2.9-C/3\n"];
    [message appendString:@"27.-30.12./\n"];
    [message appendString:@"HA/M.B-U/RG"];
    congressMessageLabel.font = [UIFont fontWithName:@"SourceCodePro-Semibold" size:40.0];
    congressMessageLabel.text = message;    
}

- (void) displayMessage {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        congressMessageLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if( finished ) {
            [self performSelector:@selector(continueAfterWelcome) withObject:self afterDelay:0.5];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMessage];
    [self displayMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
