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
#import "Workshop.h"
#import "Assembly.h"

#import "MKiCloudSync.h"

@implementation FavouritesViewController

@synthesize favouritesKeysArray;
@synthesize favouritesStored;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [favouritesStored setObject:[NSMutableArray arrayWithArray:currentFavourites] forKey:@"events"];
        [neededKeys addObject:@"events"];
    }
    
    currentFavourites = [[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeWorkshop];
    if( currentFavourites && [currentFavourites count] > 0 ) {
        [favouritesStored setObject:[NSMutableArray arrayWithArray:currentFavourites] forKey:@"workshops"];
        [neededKeys addObject:@"workshops"];
    }
    

    currentFavourites = [[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeAssembly];
    if( currentFavourites && [currentFavourites count] > 0 ) {
        [favouritesStored setObject:[NSMutableArray arrayWithArray:currentFavourites] forKey:@"assemblies"];
        [neededKeys addObject:@"assemblies"];
    }
    self.favouritesKeysArray = [NSArray arrayWithArray:neededKeys];
    [self setupTableViewHeader];
    
    [self.tableView reloadData];
}

- (SearchableItem*) nextEventOnSchedule {
    // iterate over all events and find the best fit
    NSDate *dateNow = [NSDate date];
    NSTimeInterval timeOffsetMinimum = CGFLOAT_MAX;
    SearchableItem *itemFound = nil;
    NSMutableArray *arrayOfEventsWithStartDates = [NSMutableArray array];
    [arrayOfEventsWithStartDates addObjectsFromArray:[[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeEvent]];
    [arrayOfEventsWithStartDates addObjectsFromArray:[[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeWorkshop]];
    for( FavouriteItem *currentFavourite in arrayOfEventsWithStartDates ) {
        NSTimeInterval currentOffset = CGFLOAT_MAX;
        if( currentFavourite && currentFavourite.searchableItem && currentFavourite.searchableItem.itemDateStart ) {
            currentOffset = fabs([dateNow timeIntervalSinceDate:currentFavourite.searchableItem.itemDateStart]);
        }
        if( currentOffset < timeOffsetMinimum ) {
            timeOffsetMinimum = currentOffset;
            itemFound = currentFavourite.searchableItem;
        }
    }
    return itemFound;
}

- (IBAction) actionOpenFavourite:(id)sender {
    SearchableItem *nextScheduledItem = [self nextEventOnSchedule];
    NSString *favouriteId = [[FavouriteManager sharedManager] favouriteIdFromItem:nextScheduledItem];
    FavouriteItem *currentItem = [[FavouriteManager sharedManager] favouriteItemForId:favouriteId];
    [self displayFavourite:currentItem];
}

- (void) setupTableViewHeader {
    if( [favouritesStored count] > 0 ) {
        CGFloat width = self.tableView.frame.size.width;
        UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        footerView.backgroundColor = [self themeColor];
        UIButton *buttonOpenWiki = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 40.0)];
        [buttonOpenWiki addTarget:self action:@selector(actionOpenFavourite:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:buttonOpenWiki];
        NSString *scheduledItemTitle = [NSString stringWithFormat:@"%@ - %@",[self stringShortTimeForDate:[self nextEventOnSchedule].itemDateStart], [self nextEventOnSchedule].itemTitle];
        NSString *nextEventString = [NSString stringWithFormat:@"NEXT: %@", [NSString placeHolder:LOC( @"Nothing scheduled." ) forEmptyString:scheduledItemTitle]];
        [buttonOpenWiki setTitle:nextEventString forState:UIControlStateNormal];
        [buttonOpenWiki.titleLabel setFont:[UIFont boldSystemFontOfSize:buttonOpenWiki.titleLabel.font.pointSize]];
        buttonOpenWiki.titleLabel.numberOfLines = 3;
        buttonOpenWiki.titleLabel.adjustsFontSizeToFitWidth = YES;
        [buttonOpenWiki setTitleColor:kCOLOR_WHITE forState:UIControlStateNormal];
        buttonOpenWiki.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        buttonOpenWiki.center = footerView.center;
        self.tableView.tableHeaderView = footerView;
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void) setupTableViewFooter {
    CGFloat width = self.tableView.frame.size.width;
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerView.backgroundColor = [self themeColor];

    UILabel *cloudDateLabel = [[[UILabel alloc] initWithFrame:footerView.frame] autorelease];
    cloudDateLabel.backgroundColor = kCOLOR_CLEAR;
    cloudDateLabel.numberOfLines = 3;
    cloudDateLabel.textAlignment = UITextAlignmentCenter;
    cloudDateLabel.adjustsFontSizeToFitWidth = YES;
    [footerView addSubview:cloudDateLabel];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterFullStyle;
    df.dateStyle = NSDateFormatterFullStyle;
    df.doesRelativeDateFormatting = YES;
    NSString *formattedDate = [df stringFromDate:[MKiCloudSync instance].dateLastSynced];
    [df release];
    if( [favouritesStored count] == 0 ) {
        cloudDateLabel.text = LOC( @"0 Favoriten.\nMarkiere Events, Assemblies\noder Workshops." );
    }
    else {
        cloudDateLabel.text = [NSString stringWithFormat:LOC( @"Letzter iCloud Sync:\n%@" ), [NSString placeHolder:@"n.a" forEmptyString:formattedDate]];
    }
    cloudDateLabel.font = [UIFont boldSystemFontOfSize:cloudDateLabel.font.pointSize];
    cloudDateLabel.textColor = kCOLOR_WHITE;
    cloudDateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    cloudDateLabel.center = footerView.center;
    self.tableView.tableFooterView = footerView;
}

- (void) refreshAfterCloudSync {
    [self showCloudSyncDate];
    [self refreshData];
}

- (void) showCloudSyncDate {
    [self setupTableViewFooter];
}

- (void) hideCloudSyncDate {
    self.tableView.tableFooterView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if( [MKiCloudSync instance].isActivatedRightNow ) {
        [self showCloudSyncDate];
    }
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterCloudSync) name:kMKiCloudSyncNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction) actionMultiActionSharingOnlyButtonTapped:(UIBarButtonItem*)item {
    [self presentActionSheetSharinOnlyForObject:favouritesStored fromBarButtonItem:item];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.title = LOC( @"29C3 Favoriten" );
    self.navigationItem.rightBarButtonItem = [self actionBarButtonItemSharingOnly];
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
    cell.accessoryView = [ColoredAccessoryView disclosureIndicatorViewWithColor:[self themeColor]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString* key = [favouritesKeysArray objectAtIndex:indexPath.section];
        NSMutableArray *items = [favouritesStored objectForKey:key];
        FavouriteItem *favouriteToDelete = [items objectAtIndex:indexPath.row];
        BOOL removeSuccess = [[FavouriteManager sharedManager] favouriteRemovedId:favouriteToDelete.favouriteId forItemType:favouriteToDelete.type];
        [tableView beginUpdates];
        if( removeSuccess ) {
            [items removeObject:favouriteToDelete];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
 */

- (void) displayFavourite:(FavouriteItem*)currentFavourite {
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
            detailViewController.day = eventToDisplay.day;
            detailViewController.event = eventToDisplay;
            detailViewController.navigationItem.title = eventToDisplay.itemTitle;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }
            
        case FavouriteItemTypeWorkshop: {
            NSArray *workshops = [self appDelegate].semanticWikiWorkshops;
            Workshop *workshopToDisplay = nil;
            for( Workshop *currentWorkshop in workshops ) {
                if( [[FavouriteManager sharedManager] isFavouriteIdFromItem:currentWorkshop identicalToId:currentFavourite.favouriteId] ) {
                    workshopToDisplay = currentWorkshop;
                    break;
                }
            }
            WorkshopDetailViewController *detailViewController = [[WorkshopDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
            detailViewController.workshop = workshopToDisplay;
            detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Workshop" )];
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }
            
        case FavouriteItemTypeAssembly: {
            NSArray *assemblies = [self appDelegate].semanticWikiAssemblies;
            Assembly *assemblyToDisplay = nil;
            for( Assembly *currentAssembly in assemblies ) {
                if( [[FavouriteManager sharedManager] isFavouriteIdFromItem:currentAssembly identicalToId:currentFavourite.favouriteId] ) {
                    assemblyToDisplay = currentAssembly;
                    break;
                }
            }
            AssemblyDetailViewController *detailViewController = [[AssemblyDetailViewController alloc] initWithNibName:@"AssemblyDetailViewController" bundle:nil];
            detailViewController.navigationTitle = [NSString stringWithFormat:LOC( @"Assembly" )];
            detailViewController.assembly = assemblyToDisplay;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* key = [favouritesKeysArray objectAtIndex:indexPath.section];
    NSArray *items = [favouritesStored objectForKey:key];
    FavouriteItem *currentFavourite = [items objectAtIndex:indexPath.row];
    [self displayFavourite:currentFavourite];
}

@end
