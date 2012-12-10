//
//  GenericDetailViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 10.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "GenericDetailViewController.h"

@implementation GenericDetailViewController

@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize timeStart;
@synthesize timeDuration;
@synthesize roomLabel;
@synthesize dateLabel;
@synthesize languageLabel;
@synthesize trackLabel;
@synthesize speakerLabel;

- (void) dealloc {
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.speakerLabel = nil;
    self.timeStart = nil;
    self.timeDuration = nil;
    self.roomLabel = nil;
    self.dateLabel = nil;
    self.languageLabel = nil;
    self.trackLabel = nil;
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
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.layer.masksToBounds = NO;
    NSArray *labelArray = [NSArray arrayWithObjects:titleLabel,subtitleLabel,timeStart,timeDuration,roomLabel,dateLabel,languageLabel,trackLabel,speakerLabel,nil];
    for( UILabel *currentLabel in labelArray ) {
        currentLabel.textColor = [self brighterColor];
        currentLabel.shadowColor = [[self darkColor] colorWithAlphaComponent:0.8];
        currentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
