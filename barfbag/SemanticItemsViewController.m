//
//  SemanticItemsViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 06.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "SemanticItemsViewController.h"
#import "AssemblyDetailViewController.h"
#import "WorkshopDetailViewController.h"
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
    self.navigationItem.title = LOC( @"29C3 Wikiplan" );
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC( @"Zurück" ) style:UIBarButtonItemStyleBordered target:nil action:nil];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        backgroundView.backgroundColor = [self backgroundColor];
        cell.backgroundView = backgroundView;
        UIImage *gradientImage = [self imageGradientWithSize:cell.bounds.size color1:[self themeColor] color2:[self darkerColor]];
        UIView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        selectedBackgroundView.backgroundColor = [self darkColor];
        cell.selectedBackgroundView = selectedBackgroundView;
    }
    
    // Configure the cell...
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
   switch( indexPath.section ) {
            
        case 0: {
            NSArray *workshops = [self appDelegate].semanticWikiWorkshops;
            JSONWorkshop *currentWorkshop = [workshops objectAtIndex:indexPath.row];
            NSLog( @"WORKSHOP: %@", currentWorkshop );
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"HH:mm";
            NSString *startTimeString = [df stringFromDate:currentWorkshop.startTime];
            [df release];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString placeHolder:@"<start>" forEmptyString:startTimeString], [NSString placeHolder:@"<title>"forEmptyString:currentWorkshop.label]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [NSString placeHolder:@"<location>" forEmptyString:currentWorkshop.eventLocation], [NSString placeHolder:@"<description>" forEmptyString:currentWorkshop.abstract]];
            // CHECK FAVOURITE
            cell.accessoryType = [currentWorkshop isFavourite] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }

        case 1: {
            NSArray *assemblies = [self appDelegate].semanticWikiAssemblies;
            JSONAssembly *currentAssembly = [assemblies objectAtIndex:indexPath.row];
            NSLog( @"ASSEMBLY: %@", currentAssembly );
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[currentAssembly.label placeHolderWhenEmpty:@"<title>"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:LOC( @"%i Plätze: %@" ), currentAssembly.numLectureSeats, [NSString placeHolder:@"<description>" forEmptyString:currentAssembly.abstract]];
            cell.accessoryType = [currentAssembly isFavourite] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if( indexPath.section == 0 ) {
        JSONWorkshop *workshop = [[self appDelegate].semanticWikiWorkshops objectAtIndex:indexPath.row];
        WorkshopDetailViewController *detailViewController = [[WorkshopDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
        detailViewController.workshop = workshop;
        detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Workshop #%i" ), indexPath.row+1];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    if( indexPath.section == 1 ) {
        JSONAssembly *assembly = [[self appDelegate].semanticWikiAssemblies objectAtIndex:indexPath.row];
        AssemblyDetailViewController *detailViewController = [[AssemblyDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
        detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Assembly #%i" ), indexPath.row+1];
        detailViewController.assembly = assembly;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

@end
