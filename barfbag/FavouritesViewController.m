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

#define DEBUGPERF 0

@implementation FavouritesViewController

@synthesize favouritesKeysArray;
@synthesize favouritesStored;
@synthesize upNextButton;
@synthesize timerUpdateUpNextString;
@synthesize numOfRefreshes;
@synthesize itemUpNext;
@synthesize cachedTableFooter;
@synthesize cachedTableHeader;

- (void) dealloc {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 1 +++++++++++++ dealloc" );
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if( timerUpdateUpNextString && [timerUpdateUpNextString isValid] ) {
        [timerUpdateUpNextString invalidate];
    }
    self.timerUpdateUpNextString = nil;
    self.favouritesKeysArray = nil;
    self.favouritesStored = nil;
    self.upNextButton = nil;
    self.timerUpdateUpNextString = nil;
    self.itemUpNext = nil;
    self.cachedTableFooter = nil;
    self.cachedTableHeader = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 2 +++++++++++++ initWithStyle" );
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) refreshData {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 3.1 +++++++++++++ refreshData" );
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
    if( [MKiCloudSync instance].isActivatedRightNow ) {
        [self setupTableViewFooter];
    }
    [self.tableView reloadData];
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 3.2 +++++++++++++ refreshData" );
}

- (SearchableItem*) nextEventOnSchedule {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 4 +++++++++++++ nextEventOnSchedule" );
    // iterate over all events and find the best fit
    NSTimeInterval timeOffsetMinimum = CGFLOAT_MAX;
    SearchableItem *itemFound = nil;
    NSMutableArray *arrayOfEventsWithStartDates = [NSMutableArray array];
    [arrayOfEventsWithStartDates addObjectsFromArray:[[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeEvent]];
    [arrayOfEventsWithStartDates addObjectsFromArray:[[FavouriteManager sharedManager] favouritedItemsOfType:FavouriteItemTypeWorkshop]];
    for( FavouriteItem *currentFavourite in arrayOfEventsWithStartDates ) {
        NSTimeInterval currentOffset = CGFLOAT_MAX;
        if( currentFavourite && currentFavourite.searchableItem && currentFavourite.searchableItem.itemDateStart ) {
            currentOffset = [currentFavourite.searchableItem.itemDateStart timeIntervalSinceNow];
        }
        if( currentOffset < timeOffsetMinimum && currentOffset > 0.0 ) {
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

- (void)timerStopUpNextUpdates {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 5 +++++++++++++ timerStopUpNextUpdates" );
    if( timerUpdateUpNextString && [timerUpdateUpNextString isValid] ) {
        [timerUpdateUpNextString invalidate];
    }
    self.timerUpdateUpNextString = nil;
}

- (void)timerStartUpNextUpdates {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 6 +++++++++++++ timerStartUpNextUpdates" );
    self.numOfRefreshes = 0;
    if( timerUpdateUpNextString && [timerUpdateUpNextString isValid] ) {
        [timerUpdateUpNextString invalidate];
    }
    self.timerUpdateUpNextString = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUpNextString:) userInfo:nil repeats:YES];
    [self updateUpNextString:nil];
}

- (void) refreshNextItem {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 7 +++++++++++++ refreshNextItem" );
    self.itemUpNext = [self nextEventOnSchedule];
}

- (void) updateUpNextString:(NSTimer*)timer {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 8 +++++++++++++ updateUpNextString" );
    if( !upNextButton ) return;
    if( numOfRefreshes == 0 ) {
        [self refreshNextItem];
    }
    numOfRefreshes++;
    if( numOfRefreshes > 600 ) {
        [self refreshNextItem];
        numOfRefreshes = 0;
    }
    NSInteger minutes = itemUpNext.itemMinutesTilStart % 60;
    NSInteger hours = (itemUpNext.itemMinutesTilStart-minutes)/60;
    NSInteger seconds = [[NSNumber numberWithDouble:(itemUpNext.itemSecondsTilStart - (minutes*60+hours*60*60))] integerValue];
    NSString *startsInMinutes = [NSString stringWithFormat:LOC( @"STARTS: IN %02dH %02dM %02dS" ), hours, minutes, seconds];
    NSString *scheduledItemTitle = [NSString stringWithFormat:@"%@ - %@\n%@",[NSString placeHolder:@"n.a." forEmptyString:[self stringShortTimeForDate:itemUpNext.itemDateStart]], [NSString placeHolder:@"n.a." forEmptyString:itemUpNext.itemTitle], startsInMinutes];
    NSString *nextEventString = [NSString stringWithFormat:LOC( @"UP NEXT: %@" ), [NSString placeHolder:LOC( @"Nothing scheduled." ) forEmptyString:scheduledItemTitle]];
    [upNextButton setTitle:nextEventString forState:UIControlStateNormal];
}

- (void) setupTableViewHeader {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 9 +++++++++++++ setupTableViewHeader" );
        [self refreshNextItem];
        if( [favouritesStored count] > 0 ) {
            if( !cachedTableHeader ) {
                CGFloat width = self.tableView.frame.size.width;
                self.cachedTableHeader = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 90.0)] autorelease];
                cachedTableHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                cachedTableHeader.backgroundColor = [self themeColor];

                // APPLY BACKGROUND
                UIImage *gradientImage = [self imageGradientWithSize:cachedTableHeader.bounds.size color1:[self themeColor] color2:[self darkColor]];
                UIImageView *imageBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
                imageBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                imageBackgroundView.contentMode = UIViewContentModeScaleToFill;
                [cachedTableHeader addSubview:imageBackgroundView];
                
                self.upNextButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 90.0)];
                [upNextButton addTarget:self action:@selector(actionOpenFavourite:) forControlEvents:UIControlEventTouchUpInside];
                [cachedTableHeader addSubview:upNextButton];
                [self refreshNextItem];
                NSInteger minutes = itemUpNext.itemMinutesTilStart % 60;
                NSInteger hours = (itemUpNext.itemMinutesTilStart-minutes)/60;
                NSInteger seconds = [[NSNumber numberWithDouble:(itemUpNext.itemSecondsTilStart - (minutes*60+hours*60*60))] integerValue];
                NSString *startsInMinutes = [NSString stringWithFormat:LOC( @"STARTS: IN %02dH %02dM %02dS" ), hours, minutes, seconds];
                NSString *scheduledItemTitle = [NSString stringWithFormat:@"%@ - %@\n%@",[self stringShortTimeForDate:itemUpNext.itemDateStart], itemUpNext.itemTitle, startsInMinutes];
                NSString *nextEventString = [NSString stringWithFormat:LOC( @"UP NEXT: %@" ), [NSString placeHolder:LOC( @"Nothing scheduled." ) forEmptyString:scheduledItemTitle]];
                [upNextButton setTitle:nextEventString forState:UIControlStateNormal];
                [upNextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:upNextButton.titleLabel.font.pointSize]];
                upNextButton.titleLabel.numberOfLines = 5;
                upNextButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                upNextButton.titleLabel.textAlignment = UITextAlignmentCenter;
                [upNextButton setTitleColor:kCOLOR_WHITE forState:UIControlStateNormal];
                upNextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
                upNextButton.center = cachedTableHeader.center;
            }
            self.tableView.tableHeaderView = cachedTableHeader;
        }
        else {
            self.tableView.tableHeaderView = nil;
        }
    [self timerStartUpNextUpdates];
}

- (void) setupTableViewFooter {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 10 +++++++++++++ setupTableViewFooter" );
    if( !cachedTableFooter ) {
        CGFloat width = self.tableView.frame.size.width;
        self.cachedTableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
        cachedTableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cachedTableFooter.backgroundColor = [self themeColor];

        UILabel *cloudDateLabel = [[[UILabel alloc] initWithFrame:cachedTableFooter.frame] autorelease];
        cloudDateLabel.backgroundColor = kCOLOR_CLEAR;
        cloudDateLabel.numberOfLines = 3;
        cloudDateLabel.textAlignment = UITextAlignmentCenter;
        cloudDateLabel.adjustsFontSizeToFitWidth = YES;
        [cachedTableFooter addSubview:cloudDateLabel];
        [self dateFormatter].timeStyle = NSDateFormatterFullStyle;
        [self dateFormatter].dateStyle = NSDateFormatterFullStyle;
        [self dateFormatter].doesRelativeDateFormatting = YES;
        NSString *formattedDate = [[self dateFormatter] stringFromDate:[MKiCloudSync instance].dateLastSynced];
        if( [favouritesStored count] == 0 ) {
            cloudDateLabel.text = LOC( @"0 Favoriten.\nMarkiere Events, Assemblies\noder Workshops." );
        }
        else {
            cloudDateLabel.text = [NSString stringWithFormat:LOC( @"Letzter iCloud Sync:\n%@" ), [NSString placeHolder:@"n.a" forEmptyString:formattedDate]];
        }
        cloudDateLabel.font = [UIFont boldSystemFontOfSize:cloudDateLabel.font.pointSize];
        cloudDateLabel.textColor = kCOLOR_WHITE;
        cloudDateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        cloudDateLabel.center = cachedTableFooter.center;
    }
    self.tableView.tableFooterView = cachedTableFooter;
}

- (void) refreshAfterCloudSync {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 11 +++++++++++++ refreshAfterCloudSync" );
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 12 +++++++++++++ viewWillAppear" );
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterCloudSync) name:kMKiCloudSyncNotification object:nil];
    [self timerStartUpNextUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 13 +++++++++++++ viewWillDisappear" );
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self timerStopUpNextUpdates];
}

- (IBAction) actionMultiActionSharingOnlyButtonTapped:(UIBarButtonItem*)item {
    [self presentActionSheetSharinOnlyForObject:[FavouriteManager sharedManager] fromBarButtonItem:item];
}

- (void)viewDidLoad {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 14 +++++++++++++ viewDidLoad" );
    [super viewDidLoad];
    [self refreshData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.title = LOC( @"29C3 Favoriten" );
    self.navigationItem.rightBarButtonItem = [self actionBarButtonItemSharingOnly];
    [self refreshNextItem];
}

- (void)didReceiveMemoryWarning {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 15 +++++++++++++ didReceiveMemoryWarning" );
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
    NSString* key = [NSString stringWithFormat:LOC( @"%@ (%i Einträge)" ), LOC( [favouritesKeysArray objectAtIndex:section] ), [self tableView:tableView numberOfRowsInSection:section]];
    return LOC( key );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 16.1 +++++++++++++ cellForRowAtIndexPath" );
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [self brighterColor];
        cell.detailTextLabel.textColor = [self themeColor];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
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
    SearchableItem *currentSearchableItem = [[FavouriteManager sharedManager] searchableItemForFavourite:currentFavourite];

    cell.textLabel.textColor = [self brighterColor];
    cell.detailTextLabel.textColor = [self themeColor];
    cell.backgroundView = nil;
    cell.backgroundColor = kCOLOR_CLEAR;
    // Configure the cell...
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 16.2 +++++++++++++ cellForRowAtIndexPath" );
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString placeHolder:@"--:--" forEmptyString:[self stringShortTimeForDate:currentSearchableItem.itemDateStart]], currentFavourite.favouriteName];
    cell.detailTextLabel.text = [NSString placeHolder:currentSearchableItem.itemLocation forEmptyString:@""];
    cell.accessoryView = [ColoredAccessoryView disclosureIndicatorViewWithColor:[self themeColor]];
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 16.3 +++++++++++++ cellForRowAtIndexPath" );
    if( currentSearchableItem.itemMinutesFromNow < 60 || currentSearchableItem == itemUpNext ) {
        NSInteger minutes = currentSearchableItem.itemMinutesFromNow;
        CGFloat intensityColor = (60-minutes)/60.0f;
        CGFloat hue = [[self themeColor] hue];
        CGFloat brightness = [[self themeColor] brightness];
        CGFloat saturation = [[self themeColor] saturation];
        UIColor *minuteColor =  [UIColor colorWithHue:hue saturation:saturation brightness:brightness*(0.4f+(0.6*intensityColor)) alpha:1.0];
        cell.backgroundColor = minuteColor;
        /*
        UIImage *gradientImage = [self imageGradientWithSize:cell.bounds.size color1:kCOLOR_BACK color2:minuteColor];
        UIView *normalBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
        normalBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        normalBackgroundView.backgroundColor = [self darkColor];
        cell.backgroundView = normalBackgroundView;
         */
        cell.textLabel.textColor = kCOLOR_WHITE;
        cell.detailTextLabel.textColor = kCOLOR_WHITE;
        if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 16.4 +++++++++++++ cellForRowAtIndexPath" );
    }
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 16.5 +++++++++++++ cellForRowAtIndexPath" );
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
        [self refreshNextItem];
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
    if( DEBUGPERF ) NSLog( @"++++++++++++++++++++++++++  # 17 +++++++++++++ displayFavourite" );
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
