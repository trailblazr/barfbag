//
//  FavouritesViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 07.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//
#import "AppDelegate.h"
#import "FavouritesViewController.h"
#import "FavouriteManager.h"
#import "FavouriteItem.h"

#import "EventDetailViewController.h"
#import "AssemblyDetailViewController.h"
#import "WorkshopDetailViewController.h"

#import "Conference.h"
#import "Event.h"
#import "JSONWorkshop.h"
#import "JSONAssembly.h"

@implementation FavouritesViewController

@synthesize favouritesKeysArray;
@synthesize favouritesStored;

- (void) dealloc {
    self.favouritesKeysArray = nil;
    self.favouritesStored = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) refreshData {
    self.favouritesKeysArray = nil;
    self.favouritesStored = [NSMutableDictionary dictionary];
    
    NSArray *currentFavourites = nil;
    NSMutableArray *neededKeys = [NSMutableArray array];
    
    currentFavourites = [[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeEvent];
    if( currentFavourites && [currentFavourites count] > 0 ) {
        [favouritesStored setObject:currentFavourites forKey:@"events"];
        [neededKeys addObject:@"events"];
    }
    
    currentFavourites = [[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeWorkshop];
    if( currentFavourites && [currentFavourites count] > 0 ) {
        [favouritesStored setObject:currentFavourites forKey:@"workshops"];
        [neededKeys addObject:@"workshops"];
    }
    

    currentFavourites = [[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeAssembly];
    if( currentFavourites && [currentFavourites count] > 0 ) {
        [favouritesStored setObject:currentFavourites forKey:@"assemblies"];
        [neededKeys addObject:@"assemblies"];
    }
    self.favouritesKeysArray = [NSArray arrayWithArray:neededKeys];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self refreshData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = LOC( @"29C3 Favoriten" );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [favouritesKeysArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* key = [favouritesKeysArray objectAtIndex:section];
    NSArray *items = [favouritesStored objectForKey:key];
    return [items count];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* key = [favouritesKeysArray objectAtIndex:section];
    return LOC( key );
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
    
    NSString* key = [favouritesKeysArray objectAtIndex:indexPath.section];
    NSArray *items = [favouritesStored objectForKey:key];
    FavouriteItem *currentFavourite = [items objectAtIndex:indexPath.row];

    // Configure the cell...
    cell.textLabel.text = currentFavourite.favouriteName;
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
    NSString* key = [favouritesKeysArray objectAtIndex:indexPath.section];
    NSArray *items = [favouritesStored objectForKey:key];
    FavouriteItem *currentFavourite = [items objectAtIndex:indexPath.row];
    
    switch( currentFavourite.type ) {

        case FavouriteItemTypeEvent: {
            NSArray *events = [[self conference] allEvents];
            Event *eventToDisplay = nil;
            for( Event* currentEvent in events ) {
                if( [[FavouriteManager sharedManager] isFavouriteIdFromItem:currentEvent identicalToId:currentFavourite.favouriteId] ) {
                    eventToDisplay = currentEvent;
                    break;
                }
            }
            EventDetailViewController *detailViewController = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
            detailViewController.day = nil;
            detailViewController.event = eventToDisplay;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }

        case FavouriteItemTypeWorkshop: {
            NSArray *workshops = [self appDelegate].semanticWikiWorkshops;
            JSONWorkshop *workshopToDisplay = nil;
            for( JSONWorkshop *currentWorkshop in workshops ) {
                if( [[FavouriteManager sharedManager] isFavouriteIdFromItem:currentWorkshop identicalToId:currentFavourite.favouriteId] ) {
                    workshopToDisplay = currentWorkshop;
                    break;
                }
            }            
            WorkshopDetailViewController *detailViewController = [[WorkshopDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
            detailViewController.workshop = workshopToDisplay;
            detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Workshop #%i" ), indexPath.row+1];
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }

        case FavouriteItemTypeAssembly: {
            NSArray *assemblies = [self appDelegate].semanticWikiAssemblies;
            JSONAssembly *assemblyToDisplay = nil;
            for( JSONAssembly *currentAssembly in assemblies ) {
                if( [[FavouriteManager sharedManager] isFavouriteIdFromItem:currentAssembly identicalToId:currentFavourite.favouriteId] ) {
                    assemblyToDisplay = currentAssembly;
                    break;
                }
            }
            AssemblyDetailViewController *detailViewController = [[AssemblyDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
            detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Assembly #%i" ), indexPath.row+1];
            detailViewController.assembly = assemblyToDisplay;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }

        default:
            break;
    }
}

@end
