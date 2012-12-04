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

@interface EventsViewController ()

@end

@implementation EventsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void) actionRefreshData {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[self appDelegate] barfBagRefresh];
}

- (void) actionUpdateDisplayAfterRefresh {
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_PARSER_FINISHED  object:nil];
    [super viewDidLoad];
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshData)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@", [self conference].title];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Convenient Data Access

- (Conference*) conference {
    return (Conference*)[[self appDelegate].scheduledConferences lastObject];
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:section];
    return [NSString stringWithFormat:@"%@",currentDay.date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self conference] days] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:section];
    return [[currentDay events] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
    }
    
    // Configure the cell...
    NSArray *days = [[self conference] days];
    Day *currentDay = [days objectAtIndex:indexPath.section];
    Event *currentEvent = [currentDay.events objectAtIndex:indexPath.row];
    // NSLog( @"EVENT: %@", currentEvent );
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",currentEvent.start, currentEvent.title];
    cell.detailTextLabel.text = currentEvent.subtitle;
    
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
