//
//  GenericTabBarController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "GenericTabBarController.h"
#import "AppDelegate.h"

@implementation GenericTabBarController

@synthesize hud;

- (void) dealloc {
    self.hud = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (UIColor*) themeColor {
    return [self appDelegate].themeColor;
}

- (UIColor*) brightColor {
    CGFloat hue = [[self themeColor] hue];
    return [UIColor colorWithHue:hue saturation:0.025f brightness:1.0 alpha:1.0];
}

- (UIColor*) darkColor {
    CGFloat hue = [[self themeColor] hue];
    CGFloat brightness = [[self themeColor] brightness];
    return [UIColor colorWithHue:hue saturation:1.0 brightness:brightness-0.2 alpha:1.0];
}

#pragma mark - Headup Display Management

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity {
    // ADD HUD VIEW
    if( !hud ) {
        self.hud = [[ATMHud alloc] initWithDelegate:self];
        [self.view addSubview:hud.view];
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
