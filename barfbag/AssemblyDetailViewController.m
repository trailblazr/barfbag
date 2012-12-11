//
//  AssemblyDetailViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 09.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "AssemblyDetailViewController.h"

@implementation AssemblyDetailViewController

@synthesize detailHeaderViewController;
@synthesize assembly;
@synthesize sectionKeys;
@synthesize sectionArrays;
@synthesize navigationTitle;

- (void) dealloc {
    self.assembly = nil;
    self.detailHeaderViewController = nil;
    self.sectionKeys = nil;
    self.sectionArrays = nil;
    self.navigationTitle = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = navigationTitle;
    self.navigationItem.rightBarButtonItem = [self actionBarButtonItem];
    if( !detailHeaderViewController ) {
        self.detailHeaderViewController = [[[GenericDetailViewController alloc] initWithNibName:@"GenericDetailViewController" bundle:nil] autorelease];
    }
    self.tableView.tableHeaderView = detailHeaderViewController.view;

    detailHeaderViewController.titleLabel.text = assembly.label;
    detailHeaderViewController.subtitleLabel.text = @"";
    detailHeaderViewController.timeStart.text = assembly.locationOpenedAt;
    detailHeaderViewController.timeDuration.text = @"";
    detailHeaderViewController.roomLabel.text = assembly.nameOfLocation;
    detailHeaderViewController.dateLabel.text = @"";
    detailHeaderViewController.languageLabel.text = @"";
    detailHeaderViewController.trackLabel.text = [NSString stringWithFormat:@"%i Plätze", assembly.numLectureSeats];
    detailHeaderViewController.speakerLabel.text = assembly.personOrganizing;
    
    
    // SETUP SECTION ORDER
    self.sectionKeys = [NSArray arrayWithObjects:
                        @"descriptionText",
                        @"orgaContact",
                        @"plannedWorkshops",
                        @"webLinks",
                        @"planningNotes",
                        @"bringsStuff",
                        nil];
    
    // SETUP DATA
    self.sectionArrays = [NSMutableDictionary dictionary];
    NSMutableArray *neededSectionKeys = [NSMutableArray array];
    NSArray *currentArray = nil;
    for( NSString *currentPropertyName in sectionKeys ) {
        currentArray = [assembly arrayForPropertyWithName:currentPropertyName];
        if( [currentArray count] > 0 ) {
            [neededSectionKeys addObject:currentPropertyName];
            [sectionArrays setObject:currentArray forKey:currentPropertyName];
        }
        else {
            // do nothing
        }
    }
    self.sectionKeys = [NSArray arrayWithArray:neededSectionKeys];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    return LOC( sectionKey );
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    return [[sectionArrays objectForKey:sectionKey] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    return height20;
}

- (NSString*) textToDisplayForIndexPath:(NSIndexPath*)indexPath {
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSString *itemString = [[sectionArrays objectForKey:sectionKey] objectAtIndex:indexPath.row];
    return [NSString placeHolder:LOC( @"Kein Eintrag" ) forEmptyString:itemString];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self textSizeNeededForString:[self textToDisplayForIndexPath:indexPath]].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = kCOLOR_BACK;
    }
    
    // clean existing cell
    while( [cell.contentView.subviews count] > 0 ) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    CGSize textSize = [self textSizeNeededForString:[self textToDisplayForIndexPath:indexPath]];
    UILabel *cellTextLabel = [self cellTextLabelWithRect:CGRectMake(5.0, 0.0, textSize.width, textSize.height-10)];
    [cell.contentView addSubview:cellTextLabel];
    
    // Configure the cell...
    cellTextLabel.text = [self textToDisplayForIndexPath:indexPath];
    return cell;
}

/*
// Configure the cell...
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSString *itemString = [[sectionArrays objectForKey:sectionKey] objectAtIndex:indexPath.row];
    cell.textLabel.text = itemString;
*/

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
