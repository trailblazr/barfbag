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

- (UIImage*) imageGradientWithSize:(CGSize)imageSize color1:(UIColor*)color1 color2:(UIColor*)color2 {
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else {
        UIGraphicsBeginImageContext(imageSize);
    }
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(c);
    
    // draw gradient
	CGGradientRef gradient;
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[2] = { 0.0, 1.0 };
    
	// step 3: define gradient with components
	CGFloat colors[] = {
        [color1 red],[color1 green],[color1 blue],[color1 alpha],
        [color2 red],[color2 green],[color2 blue],[color2 alpha]
	};
    
    gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, sizeof(colors)/(sizeof(colors[0])*4));
	//gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	// gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 0);
	
	CGPoint start, end;
	start = CGPointMake( 0.0, 0.0 );
	end = CGPointMake( 0.0, imageSize.height );
    CGContextClearRect(c, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height) );
	CGContextDrawLinearGradient(c, gradient, start, end, 0);
	
	// release c-stuff
	CGColorSpaceRelease(rgb);
	CGGradientRelease(gradient);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(c);
    
    UIGraphicsEndImageContext();
    return image;
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
    titleLabel.textColor = [self brightColor];
    speakerLabel.textColor = [self themeColor];

    // APPLY BACKGROUND
    UIImage *gradientImage = [self imageGradientWithSize:self.view.bounds.size color1:[self themeColor] color2:[self backgroundColor]];
    UIImageView *imageBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    imageBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    imageBackgroundView.contentMode = UIViewContentModeScaleToFill;
    [self.view insertSubview:imageBackgroundView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
