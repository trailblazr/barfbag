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
@synthesize sharedDateFormatter;

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
    self.view.backgroundColor = [self backgroundColor];
}

- (NSDateFormatter*) dateFormatter {
    if( !sharedDateFormatter ) {
        self.sharedDateFormatter = [[NSDateFormatter alloc] init];
    }
    return sharedDateFormatter;
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

- (NSString*) stringDayForDate:(NSDate*)date withDayFormat:(NSString*)dayFormat {
    if( !date ) return nil;
    [self dateFormatter].timeStyle = NSDateFormatterNoStyle;
    [self dateFormatter].dateStyle = NSDateFormatterMediumStyle;
    [self dateFormatter].dateFormat = [NSString stringWithFormat:@"%@, %@", dayFormat, [self dateFormatter].dateFormat];
    NSString *formattedDate = [[self dateFormatter] stringFromDate:date];
    return formattedDate;
}

- (NSString*) stringDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eeee"];
}

- (NSString*) stringShortDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eee"];
}

#pragma mark - Colors

- (UIColor*) backgroundColor {
    return [self appDelegate].backgroundColor;
}

- (UIColor*) themeColor {
    return [self appDelegate].themeColor;
}

- (UIColor*) brightColor {
    return [self appDelegate].brightColor;
}

- (UIColor*) brighterColor {
    return [self appDelegate].brighterColor;
}

- (UIColor*) darkColor {
    return [self appDelegate].darkColor;
}

- (UIColor*) darkerColor {
    return [self appDelegate].darkerColor;
}

- (UIColor*) backBrightColor {
    return [self appDelegate].backBrightColor;
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
