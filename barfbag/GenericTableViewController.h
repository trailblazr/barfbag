//
//  GenericTableViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import "WebbrowserViewController.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "Conference.h"
#import "ColoredAccessoryView.h"

@class AppDelegate;

@interface GenericTableViewController : UITableViewController <ATMHudDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,WebbrowserViewControllerDelegate> {

    ATMHud *hud;
    id reminderObject;
    BOOL isSearching;
    BOOL isUserAllowedToSelectRow;
    NSMutableArray *searchItemsFiltered;
    NSDateFormatter *sharedDateFormatter;
}

@property( nonatomic, assign ) BOOL isSearching;
@property( nonatomic, assign ) BOOL isUserAllowedToSelectRow;
@property( nonatomic, retain ) ATMHud *hud;
@property( nonatomic, retain ) id reminderObject;
@property( nonatomic, retain ) NSMutableArray *searchItemsFiltered;
@property( nonatomic, retain ) NSDateFormatter *sharedDateFormatter;

- (NSDateFormatter*) dateFormatter;

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity;
- (void) hideHud;

- (AppDelegate*) appDelegate;

- (UILabel*) cellTextLabelWithRect:(CGRect)rect;

- (NSString*) stringDayForDate:(NSDate*)date;
- (NSString*) stringShortDayForDate:(NSDate*)date;
- (NSString*) stringTimeForDate:(NSDate*)date;
- (NSString*) stringForDate:(NSDate*)date withFormat:(NSString*)format;
- (NSString*) stringDayForDate:(NSDate*)date withDayFormat:(NSString*)dayFormat;
- (NSString*) stringShortTimeForDate:(NSDate*)date;

- (CGSize) textSizeNeededForString:(NSString*)textToDisplay;
- (UIImage*) imageGradientWithSize:(CGSize)imageSize color1:(UIColor*)color1 color2:(UIColor*)color2;

- (UIColor*) backgroundColor;
- (UIColor*) themeColor;
- (UIColor*) brightColor;
- (UIColor*) brighterColor;
- (UIColor*) darkColor;
- (UIColor*) darkerColor;
- (UIColor*) backBrightColor;

- (Conference*) conference;

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void) presentActionSheetForObject:(id)objectToOperate fromBarButtonItem:(UIBarButtonItem*)item;
- (void) presentActionSheetSharinOnlyForObject:(id)objectInProgress fromBarButtonItem:(UIBarButtonItem*)item;
- (IBAction) actionMultiActionButtonTapped:(id)sender;
- (IBAction) actionMultiActionSharingOnlyButtonTapped:(id)sender;
- (UIBarButtonItem*) actionBarButtonItem;
- (UIBarButtonItem*) actionBarButtonItemSharingOnly;

- (NSArray*) allSearchableItems;
- (void) loadSimpleWebViewWithURL:(NSURL*)url shouldScaleToFit:(BOOL)shouldScaleToFit;
- (void) loadSimpleWebViewWithURL:(NSURL*)url shouldScaleToFit:(BOOL)shouldScaleToFit isModal:(BOOL)isModal;
- (void) sendMailToRecipientAddress:(NSString*)mailTo;

@end
