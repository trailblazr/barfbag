//
//  GenericTableViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "Conference.h"

@class AppDelegate;

@interface GenericTableViewController : UITableViewController <ATMHudDelegate,UIActionSheetDelegate> {

    ATMHud *hud;
    id reminderObject;
}

@property( nonatomic, retain ) ATMHud *hud;
@property( nonatomic, retain ) id reminderObject;

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

- (AppDelegate*) appDelegate;

- (UILabel*) cellTextLabelWithRect:(CGRect)rect;

- (NSString*) stringDayForDate:(NSDate*)date;
- (NSString*) stringShortDayForDate:(NSDate*)date;
- (NSString*) stringTimeForDate:(NSDate*)date;

- (CGSize) textSizeNeededForString:(NSString*)textToDisplay;
- (UIImage*) imageGradientWithSize:(CGSize)imageSize color1:(UIColor*)color1 color2:(UIColor*)color2;

- (UIColor*) backgroundColor;
- (UIColor*) themeColor;
- (UIColor*) brightColor;
- (UIColor*) brighterColor;
- (UIColor*) darkColor;
- (UIColor*) darkerColor;

- (Conference*) conference;

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;

- (void) presentActionSheetForObject:(id)objectToOperate fromBarButtonItem:(UIBarButtonItem*)item;
- (IBAction) actionMultiActionButtonTapped:(id)sender;
- (UIBarButtonItem*) actionBarButtonItem;

@end
