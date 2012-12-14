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
#import "EventDetailViewController.h"

@implementation EventsViewController

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
        return LOC( @"29C3 Fahrplan" );
    }
    if( !title || [title length] == 0 ) {
        return LOC( @"Ereignisse" );
    }
    else {
        return title;
    }
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

- (IBAction) actionButtonTapped:(id)sender {
    NSLog( @"BUTTON TAPPED." );
}

- (IBAction) actionSearch:(id)sender {
    
}

- (IBAction) actionMultiActionButtonTapped:(id)sender {
    NSLog( @"ACTION TAPPED." );
    
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_PARSER_COMPLETED  object:nil];
    [super viewDidLoad];
        
    if( [self tableView:self.tableView numberOfRowsInSection:0] == 0 ) {
        [[self appDelegate] barfBagLoadCached];
    }
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LOC( @"Zurück" ) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshData)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
    [self updateNavigationTitle];
    
    
    
    // FOOTER
    CGFloat width = self.view.bounds.size.width;
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
    footerView.backgroundColor = kCOLOR_CLEAR;
    UILabel *versionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width-20.0f, 70.0)] autorelease];
    versionLabel.backgroundColor = kCOLOR_CLEAR;
    versionLabel.numberOfLines = 3;
    versionLabel.textAlignment = UITextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"Fahrplan: %@", [self appDelegate].barfBagCurrentDataVersion];
    versionLabel.font = [UIFont boldSystemFontOfSize:14.0];
    versionLabel.textColor = [self brighterColor];
    [footerView addSubview:versionLabel];
    versionLabel.center = footerView.center;
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = footerView;
    /*
    UIImage *searchFieldBackgroundImage = [self imageGradientWithSize:self.searchDisplayController.searchBar.bounds.size color1:[self themeColor] color2:[self darkColor]];
;
    [self.searchDisplayController.searchBar setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    */
    
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if( isSearching ) {
        return [NSString stringWithFormat:LOC( @"%i Treffer" ), [searchItemsFiltered count] ];
    }
    else {
        NSArray *days = [[self conference] days];
        Day *currentDay = [days objectAtIndex:section];
        return [NSString stringWithFormat:LOC( @"%@  –  %i Events" ),[self stringShortDayForDate:currentDay.date], [currentDay.events count]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if( isSearching ) {
        return 1;
    }
    else {
        return [[[self conference] days] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( isSearching ) {
        return [searchItemsFiltered count];
    }
    else {
        NSArray *days = [[self conference] days];
        Day *currentDay = [days objectAtIndex:section];
        return [[currentDay events] count];
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [self brighterColor];
        cell.detailTextLabel.textColor = [self themeColor];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        backgroundView.backgroundColor = [self backgroundColor];
        cell.backgroundView = backgroundView;
        UIImage *gradientImage = [self imageGradientWithSize:cell.bounds.size color1:[self themeColor] color2:[self darkerColor]];
        UIView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        selectedBackgroundView.backgroundColor = [self darkColor];
        cell.selectedBackgroundView = selectedBackgroundView;
        /*
        UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favButton.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        [favButton setImage:[UIImage imageNamed:@"favourites.png"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
         */
        cell.accessoryView = nil;
    }
    
    // Configure the cell...
    Event *currentEvent = nil;
    if( isSearching ) {
        currentEvent = [searchItemsFiltered objectAtIndex:indexPath.row];
    }
    else {
        NSArray *days = [[self conference] days];
        Day *currentDay = [days objectAtIndex:indexPath.section];
        currentEvent = [currentDay.events objectAtIndex:indexPath.row];
    }
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
    EventDetailViewController *detailViewController = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
    if( isSearching ) {
        Event *currentEvent = [searchItemsFiltered objectAtIndex:indexPath.row];
        Day *currentDay = currentEvent.day;
        detailViewController.day = currentDay;
        detailViewController.event = currentEvent;
    }
    else {
        NSArray *days = [[self conference] days];
        Day *currentDay = [days objectAtIndex:indexPath.section];
        Event *currentEvent = [currentDay.events objectAtIndex:indexPath.row];
        detailViewController.day = currentDay;
        detailViewController.event = currentEvent;
    }
    [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
}

#pragma mark - UISearchBarDelegate

- (NSArray*) allSearchableItems {
    // ATTN: NEEDS TO BE OVERRIDDEN IN SUBCLASS TO HAVE SEARCH WORKING
    return [[self conference] allEvents];
}

@end
