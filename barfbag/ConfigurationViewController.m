//
//  ConfigurationViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"

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
        self.sectionsArray = [NSMutableArray array];
        self.tableView.backgroundColor = [self themeColor];
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
    self.navigationItem.title = LOC( @"Einstellungen" );
    self.tableView.backgroundColor = [self themeColor];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [sectionsArray count];
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
