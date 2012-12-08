//
//  EventsViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "EventsViewController.h"
#import "AppDelegate.h"
#import "Conference.h"
#import "Day.h"
#import "Event.h"
#import "AppDelegate.h"

@implementation EventsViewController

@synthesize isSearching;

- (void) dealloc {
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Convenience Methods

- (void) updateNavigationTitle {
    self.navigationItem.titleView = nil;
    BOOL useCustomTitleView = NO;
    if( useCustomTitleView ) {
        self.navigationItem.titleView = [self navigationTitleView];
    }
    else {
        self.navigationItem.title = [self navigationTitleString];
    }
}

- (UIView*) navigationTitleView {
    CGFloat width = self.view.bounds.size.width-40.0f;
    CGFloat height = self.navigationController.navigationBar.bounds.size.height;
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)] autorelease];
    titleLabel.textColor = kCOLOR_WHITE;
    titleLabel.backgroundColor = kCOLOR_CLEAR;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = [self navigationTitleString];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    return titleLabel;
}

- (NSString*) navigationTitleString {
    NSString *title = [self conference].title;
    BOOL shouldOverrideScheduleTitle = YES;
    if( shouldOverrideScheduleTitle ) {
        return LOC( @"Fahrplan" );
    }
    if( !title || [title length] == 0 ) {
        return LOC( @"Ereignisse" );
    }
    else {
        return title;
    }
}

- (NSString*) stringDayForDate:(NSDate*)date {
    if( !date ) return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    NSString *formattedDate = [df stringFromDate:date];
    [df release];
    return formattedDate;
}

- (Conference*) conference {
    return (Conference*)[[self appDelegate].scheduledConferences lastObject];
}

#pragma mark - User Actions

- (void) actionRefreshData {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[self appDelegate] barfBagRefresh];
}

- (void) actionUpdateDisplayAfterRefresh {
    [self.tableView reloadData];
    [self updateNavigationTitle];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (IBAction) actionSearch:(id)sender {
    
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_PARSER_COMPLETED  object:nil];
    [super viewDidLoad];
    if( [self tableView:self.tableView numberOfRowsInSection:0] == 0 ) {
        [[self appDelegate] barfBagLoadCached];
    }
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshData)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
    [self updateNavigationTitle];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    return height20;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    CGFloat fontSize16 = [[UIDevice currentDevice] isPad] ? 32.0f : 16.0f;
    CGRect containerRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, height20);
    UIView *containerView = [[[UIView alloc] initWithFrame:containerRect] autorelease];
    containerView.opaque = NO;
    containerView.backgroundColor = [[self themeColor] colorWithAlphaComponent:0.9f];
    CGFloat offset = 10.0f;
    CGRect labelRect = CGRectMake(offset, 0.0, containerRect.size.width-(2*offset), containerRect.size.height);
    UILabel *label = [[[UILabel alloc] initWithFrame:labelRect] autorelease];
    [containerView addSubview:label];
    label.backgroundColor = kCOLOR_CLEAR;
    label.font = [UIFont boldSystemFontOfSize:fontSize16];
    label.textColor = kCOLOR_WHITE;
    label.shadowColor = [kCOLOR_BLACK colorWithAlphaComponent:0.5];
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    return containerView;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:section];
    return [NSString stringWithFormat:@"%@",[self stringDayForDate:currentDay.date]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self conference] days] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:section];
    return [[currentDay events] count];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        backgroundView.backgroundColor = [self brightColor];
        cell.backgroundView = backgroundView;
        UIImage *gradientImage = [self imageGradientWithSize:cell.bounds.size color1:[self themeColor] color2:[self darkColor]];
        UIView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        selectedBackgroundView.backgroundColor = [self darkColor];
        cell.selectedBackgroundView = selectedBackgroundView;
    }
    
    // Configure the cell...
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:indexPath.section];
    Event *currentEvent = [currentDay.events objectAtIndex:indexPath.row];
    // NSLog( @"EVENT: %@", currentEvent );
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[currentEvent.start placeHolderWhenEmpty:@"<start>"], [currentEvent.title placeHolderWhenEmpty:@"<title>"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",[currentEvent.track placeHolderWhenEmpty:@"<track>"], [currentEvent.subtitle placeHolderWhenEmpty:@"<subtitle>"]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UISearchBarDelegate

- (void) searchFilterEventsDisplayed {
    /*
    NSString *searchText = searchBar.text;
    
    for (Event *aEvent in appDelegate.events) {
        NSRange titleResultsRange = [aEvent.title rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange subtitleResultsRange = [aEvent.subtitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange abstractResultsRange = [aEvent.abstract rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange speakerResultsRange = [aEvent.speaker rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0 || subtitleResultsRange.length > 0 || abstractResultsRange.length > 0 || speakerResultsRange.length >0)
            [searchAllEvents addObject:aEvent];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"realDate" ascending:TRUE];
    [searchAllEvents sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
     */
}


@end
