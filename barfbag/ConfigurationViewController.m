//
//  ConfigurationViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"

#define kTABLE_SECTION_HEADER_HEIGHT 50.0f

@implementation ConfigurationViewController

@synthesize sectionsArray;

- (void) dealloc {
    self.sectionsArray = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateDefaultsForKey:(NSString*)key withValue:(BOOL)isOn {
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) actionSwitchChanged:(UISwitch*)theSwitch {
    if( theSwitch == [sectionsArray objectAtIndex:0] ) {
        [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE withValue:theSwitch.isOn];
    }
}

- (void) setupSwitches {
    self.sectionsArray = [NSMutableArray array];
    UISwitch *switchRefreshDataOnStartup = [[[UISwitch alloc] init] autorelease];
    switchRefreshDataOnStartup.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE defaultValue:YES];
    [switchRefreshDataOnStartup addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [sectionsArray addObject:switchRefreshDataOnStartup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSwitches];
    [self.tableView reloadData];
    self.tableView.backgroundColor = [self brighterColor];
    self.navigationItem.title = LOC( @"Einstellungen" );
    
    // FOOTER
    CGFloat width = self.view.bounds.size.width;
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
    footerView.backgroundColor = kCOLOR_CLEAR;
    UILabel *creditsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width-20.0f, 70.0)] autorelease];
    creditsLabel.backgroundColor = kCOLOR_CLEAR;
    creditsLabel.numberOfLines = 3;
    creditsLabel.textAlignment = UITextAlignmentCenter;
    creditsLabel.text = LOC( @"created in 2012 by trailblazr\nwith some help & code of plaetzchen" );
    creditsLabel.font = [UIFont systemFontOfSize:12.0];
    creditsLabel.textColor = kCOLOR_BLACK;
    [footerView addSubview:creditsLabel];
    creditsLabel.center = footerView.center;
    creditsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = footerView;
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
    CGFloat height50 = [[UIDevice currentDevice] isPad] ? kTABLE_SECTION_HEADER_HEIGHT*1.5f : kTABLE_SECTION_HEADER_HEIGHT;
    return height50;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = self.view.bounds.size.width;
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kTABLE_SECTION_HEADER_HEIGHT)] autorelease];
    headerView.backgroundColor = kCOLOR_CLEAR;
    CGFloat offsetLeftRight = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    UILabel *sectionHeader = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width-offsetLeftRight, kTABLE_SECTION_HEADER_HEIGHT)] autorelease];
    sectionHeader.backgroundColor = kCOLOR_CLEAR;
    sectionHeader.numberOfLines = 3;
    sectionHeader.textAlignment = UITextAlignmentLeft;
    sectionHeader.text = LOC( @"Optionen" );
    CGFloat fontSize17 = [[UIDevice currentDevice] isPad] ? 34.0 : 17.0;
    sectionHeader.font = [UIFont boldSystemFontOfSize:fontSize17];
    sectionHeader.shadowColor = [kCOLOR_WHITE colorWithAlphaComponent:0.3];
    sectionHeader.shadowOffset = CGSizeMake(1.0, 1.0);
    sectionHeader.textColor = kCOLOR_BLACK;
    [headerView addSubview:sectionHeader];
    sectionHeader.center = headerView.center;
    return headerView;
}

/*
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return LOC( @"Optionen" );
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [sectionsArray count];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    // Configure the cell...
    UIView *currentView = [sectionsArray objectAtIndex:indexPath.row];
    switch( indexPath.row ) {
        case 0:
            cell.textLabel.text = LOC( @"Autoupdate" );
            cell.detailTextLabel.text = LOC( @"Aktualisiere alle Daten beim Start" );
            cell.accessoryView = currentView;
            break;
            
        default:
            break;
    }
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

@end
