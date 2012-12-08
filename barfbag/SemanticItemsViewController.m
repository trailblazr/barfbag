//
//  SemanticItemsViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 06.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "SemanticItemsViewController.h"
#import "AppDelegate.h"
#import "JSONAssembly.h"
#import "JSONWorkshop.h"

@implementation SemanticItemsViewController

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
    self.navigationItem.title = LOC( @"Wikiplan" );
}

#pragma mark - User Actions

- (void) actionRefreshData {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[self appDelegate] semanticWikiRefresh];
}

- (void) actionUpdateDisplayAfterRefresh {
    [self.tableView reloadData];
    [self updateNavigationTitle];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_JSON_COMPLETED  object:nil];
    [super viewDidLoad];
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshData)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
    [self updateNavigationTitle];
    if( [self tableView:self.tableView numberOfRowsInSection:0] == 0 ) {
        [[self appDelegate] semanticWikiLoadCached];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
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
    switch (section) {
        case 0:
            return [NSString stringWithFormat:LOC( @"%i Workshops" ), [[self appDelegate].semanticWikiWorkshops count]];
            break;

        case 1:
            return [NSString stringWithFormat:LOC( @"%i Assemblies" ), [[self appDelegate].semanticWikiAssemblies count]];
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
            
        case 0:
            return [[self appDelegate].semanticWikiWorkshops count];
            break;

        case 1:
            return [[self appDelegate].semanticWikiAssemblies count];
            break;

        default:
            break;
    }
    return 0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = kCOLOR_WHITE;
    cell.contentView.backgroundColor = kCOLOR_WHITE;
    cell.accessoryView.backgroundColor = kCOLOR_WHITE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    switch( indexPath.section ) {
            
        case 0: {
            NSArray *workshops = [self appDelegate].semanticWikiWorkshops;
            JSONWorkshop *currentWorkshop = [workshops objectAtIndex:indexPath.row];
            // NSLog( @"WORKSHOP: %@", currentWorkshop );
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"HH:mm";
            NSString *startTimeString = [df stringFromDate:currentWorkshop.startTime];
            [df release];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString placeHolder:@"--:--" forEmptyString:startTimeString], [NSString placeHolder:@"n.a."forEmptyString:currentWorkshop.label]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@]: %@", [NSString placeHolder:@"-" forEmptyString:currentWorkshop.eventLocation], [NSString placeHolder:@"n.a." forEmptyString:currentWorkshop.abstract]];
            break;
        }

        case 1: {
            NSArray *assemblies = [self appDelegate].semanticWikiAssemblies;
            JSONAssembly *currentAssembly = [assemblies objectAtIndex:indexPath.row];
            // NSLog( @"ASSEMBLY: %@", currentAssembly );
            cell.textLabel.text = [NSString stringWithFormat:@"%@",currentAssembly.label];
            cell.detailTextLabel.text = [NSString stringWithFormat:LOC( @"[%i Plätze]: %@" ), currentAssembly.numLectureSeats, [NSString placeHolder:@"n.a." forEmptyString:currentAssembly.abstract]];
            break;
        }

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
