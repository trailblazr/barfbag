//
//  ConfigurationViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"
#import "MasterConfig.h"
#import "MKiCloudSync.h"

#define kTABLE_SECTION_HEADER_HEIGHT 50.0f

@implementation ConfigurationViewController

@synthesize sectionsArray;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - Convenience Methods

- (void) updateDefaultsForKey:(NSString*)key withValue:(BOOL)isOn {
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
    
}

- (UIImage*) imageFromView:(UIView*)viewToRender {
    UIGraphicsBeginImageContext(viewToRender.frame.size);
    [[viewToRender layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

- (void) refreshAllDataAfterForceReconfig {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - User Actions

- (IBAction) actionRefreshAllData {
    [[self appDelegate] allDataRefresh];
}

- (IBAction) actionSwitchChanged:(UISwitch*)theSwitch {
    for( NSDictionary *currentDict in sectionsArray ) {
        if( [currentDict objectForKey:@"switchAutoUpdate"] == theSwitch ) {
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE withValue:theSwitch.isOn];
        }
        if( [currentDict objectForKey:@"switchFailover"] == theSwitch ) {
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_FAILOVER withValue:theSwitch.isOn];
        }
        if( [currentDict objectForKey:@"switchImageUpdates"] == theSwitch ) {
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_IMAGEUPDATE withValue:theSwitch.isOn];
        }
        if( [currentDict objectForKey:@"switchCloudSync"] == theSwitch ) {
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_USE_CLOUD_SYNC withValue:theSwitch.isOn];
            if( theSwitch.isOn ) {
                [[MKiCloudSync instance] start];
                [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
            }
            else {
                [[MKiCloudSync instance] stop];
                [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
            }
        }
        if( [currentDict objectForKey:@"switchTimeFocus"] == theSwitch ) {
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_USE_TIME_FOCUS withValue:theSwitch.isOn];
        }
    }
}

- (IBAction) actionForceReconfigureClient {
    UISwitch *currentSwitch = nil;
    for( NSDictionary *currentDict in sectionsArray ) {
        currentSwitch = (UISwitch*)[currentDict objectForKey:@"switchAutoUpdate"];
        if( currentSwitch ) {
            [currentSwitch setOn:YES animated:YES];
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE withValue:YES];
        }
        currentSwitch = (UISwitch*)[currentDict objectForKey:@"switchFailover"];
        if( currentSwitch ) {
            [currentSwitch setOn:NO animated:YES];
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_FAILOVER withValue:NO];
        }
        currentSwitch = (UISwitch*)[currentDict objectForKey:@"switchImageUpdates"];
        if( currentSwitch ) {
            [currentSwitch setOn:YES animated:YES];
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_IMAGEUPDATE withValue:YES];
        }
        currentSwitch = (UISwitch*)[currentDict objectForKey:@"switchCloudSync"];
        if( currentSwitch ) {
            [currentSwitch setOn:YES animated:YES];
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_USE_CLOUD_SYNC withValue:YES];
        }
        currentSwitch = (UISwitch*)[currentDict objectForKey:@"switchTimeFocus"];
        if( currentSwitch ) {
            [currentSwitch setOn:YES animated:YES];
            [self updateDefaultsForKey:kUSERDEFAULT_KEY_BOOL_USE_TIME_FOCUS withValue:YES];
        }
    }
    [[self appDelegate] emptyAllFilesFromFolder:kFOLDER_DOCUMENTS];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllDataAfterForceReconfig) name:kNOTIFICATION_MASTER_CONFIG_COMPLETED object:nil];
    [[MasterConfig sharedConfiguration] refreshFromMothership];
}

- (void) setupTableData {
    self.sectionsArray = [NSMutableArray array];
    NSDictionary *itemEntry = nil;    
    
    // SWITCH AUTOUPDATE
    UISwitch *switchRefreshDataOnStartup = [[[UISwitch alloc] init] autorelease];
    switchRefreshDataOnStartup.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_AUTOUPDATE defaultValue:YES];
    [switchRefreshDataOnStartup addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    itemEntry = [NSDictionary dictionaryWithObject:switchRefreshDataOnStartup forKey:@"switchAutoUpdate"];
    [sectionsArray addObject:itemEntry];

    // SWITCH UPDATE IMAGES
    UISwitch *switchUpdateImagesOnStartup = [[[UISwitch alloc] init] autorelease];
    switchUpdateImagesOnStartup.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_IMAGEUPDATE defaultValue:YES];
    [switchUpdateImagesOnStartup addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    itemEntry = [NSDictionary dictionaryWithObject:switchUpdateImagesOnStartup forKey:@"switchImageUpdates"];
    [sectionsArray addObject:itemEntry];

    // SWITCH PERMANENT FAILOVER
    UISwitch *switchUseFailoverPermanent = [[[UISwitch alloc] init] autorelease];
    switchUseFailoverPermanent.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_FAILOVER defaultValue:NO];
    [switchUseFailoverPermanent addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    itemEntry = [NSDictionary dictionaryWithObject:switchUseFailoverPermanent forKey:@"switchFailover"];
    [sectionsArray addObject:itemEntry];

    // SWITCH ICLOUD SYNC
    UISwitch *switchUseCloudSync = [[[UISwitch alloc] init] autorelease];
    switchUseCloudSync.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_USE_CLOUD_SYNC defaultValue:YES];
    [switchUseCloudSync addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    itemEntry = [NSDictionary dictionaryWithObject:switchUseCloudSync forKey:@"switchCloudSync"];
    [sectionsArray addObject:itemEntry];

    // SWITCH TIME FOCUS
    UISwitch *switchTimeFocus = [[[UISwitch alloc] init] autorelease];
    switchTimeFocus.on = [[self appDelegate] isConfigOnForKey:kUSERDEFAULT_KEY_BOOL_USE_TIME_FOCUS defaultValue:YES];
    [switchTimeFocus addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    itemEntry = [NSDictionary dictionaryWithObject:switchTimeFocus forKey:@"switchTimeFocus"];
    [sectionsArray addObject:itemEntry];

    // BUTTON RESET
    UIButton *buttonForceReconfiguration = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonForceReconfiguration.layer.cornerRadius = 7.0;
    buttonForceReconfiguration.layer.borderColor = [self darkerColor].CGColor;
    buttonForceReconfiguration.layer.borderWidth = 1.0;
    buttonForceReconfiguration.layer.masksToBounds = YES;
    buttonForceReconfiguration.backgroundColor = [self darkColor];
    buttonForceReconfiguration.frame = CGRectMake(0.0, 0.0, 85.0, 30.0);
    [buttonForceReconfiguration setTitle:LOC( @"Reconfig" ) forState:UIControlStateNormal];
    [buttonForceReconfiguration setTitleColor:kCOLOR_WHITE forState:UIControlStateNormal];
    [buttonForceReconfiguration setTitleColor:kCOLOR_WHITE forState:UIControlStateHighlighted];
    buttonForceReconfiguration.titleLabel.font = [UIFont boldSystemFontOfSize:buttonForceReconfiguration.titleLabel.font.pointSize];
    // NORMAL BUTTON
    UIImage *gradientImage = [self imageGradientWithSize:buttonForceReconfiguration.bounds.size color1:[self themeColor] color2:[self darkColor]];
    UIImageView *maskedImageView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    maskedImageView.layer.cornerRadius = 7.0;
    maskedImageView.layer.masksToBounds = YES;
    gradientImage = [self imageFromView:maskedImageView];
    [buttonForceReconfiguration setBackgroundImage:gradientImage forState:UIControlStateNormal];

    // PRESSED BUTTON
    gradientImage = [self imageGradientWithSize:buttonForceReconfiguration.bounds.size color1:[self brighterColor] color2:[self themeColor]];
    maskedImageView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    maskedImageView.layer.cornerRadius = 7.0;
    maskedImageView.layer.masksToBounds = YES;
    gradientImage = [self imageFromView:maskedImageView];
    [buttonForceReconfiguration setBackgroundImage:gradientImage forState:UIControlStateHighlighted];
    [buttonForceReconfiguration addTarget:self action:@selector(actionForceReconfigureClient) forControlEvents:UIControlEventTouchUpInside];
    itemEntry = [NSDictionary dictionaryWithObject:buttonForceReconfiguration forKey:@"buttonForceReconfig"];
    [sectionsArray addObject:itemEntry];

    
    // BUTTON RESET
    UIButton *buttonUpdateAllData = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonUpdateAllData.frame = CGRectMake(10.0, 7.0, 280.0, 50.0);
    buttonUpdateAllData.layer.cornerRadius = 7.0;
    buttonUpdateAllData.layer.borderColor = [self darkerColor].CGColor;
    buttonUpdateAllData.layer.borderWidth = 1.0;
    buttonUpdateAllData.layer.masksToBounds = YES;
    buttonUpdateAllData.backgroundColor = [self themeColor];
    buttonUpdateAllData.titleLabel.shadowOffset = CGSizeMake(0.0,0.0);
    buttonUpdateAllData.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [buttonUpdateAllData setTitle:LOC( @"Update All Data" ) forState:UIControlStateNormal];
    [buttonUpdateAllData setTitleColor:kCOLOR_WHITE forState:UIControlStateNormal];
    [buttonUpdateAllData setTitleColor:kCOLOR_WHITE forState:UIControlStateHighlighted];
    buttonUpdateAllData.titleLabel.font = [UIFont boldSystemFontOfSize:buttonUpdateAllData.titleLabel.font.pointSize];
    // MASK BUTTON
    gradientImage = [self imageGradientWithSize:buttonUpdateAllData.bounds.size color1:[self themeColor] color2:[self darkerColor]];
    maskedImageView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    maskedImageView.layer.cornerRadius = 7.0;
    maskedImageView.layer.masksToBounds = YES;
    gradientImage = [self imageFromView:maskedImageView];
    [buttonUpdateAllData setBackgroundImage:gradientImage forState:UIControlStateHighlighted];
    [buttonUpdateAllData addTarget:self action:@selector(actionRefreshAllData) forControlEvents:UIControlEventTouchUpInside];
    itemEntry = [NSDictionary dictionaryWithObject:buttonUpdateAllData forKey:@"buttonRefreshAllData"];
    [sectionsArray addObject:itemEntry];
    
}

- (NSString*) versionInfo {
    return 	(NSString*)[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableData];
    // self.tableView.separatorColor = [self darkColor];
    [self.tableView reloadData];
    self.navigationItem.title = LOC( @"29C3 Einstellungen" );
    
    // FOOTER
    CGFloat width = self.view.bounds.size.width;
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 80.0)] autorelease];
    footerView.backgroundColor = kCOLOR_CLEAR;
    UILabel *creditsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width-20.0f, 80.0)] autorelease];
    creditsLabel.backgroundColor = kCOLOR_CLEAR;
    creditsLabel.numberOfLines = 4;
    creditsLabel.textAlignment = UITextAlignmentCenter;
    creditsLabel.text = [NSString stringWithFormat:LOC( @"%@ created in 2012 by trailblazr\nwith some help & code of plaetzchen" ), [self versionInfo]];
    creditsLabel.font = [[self appDelegate] fontWithType:CustomFontTypeSemibold andPointSize:12];
    creditsLabel.textColor = [self themeColor];
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

#define kUSE_SECTION_HEADER NO

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
#if kUSE_SECTION_HEADER
    CGFloat height50 = [[UIDevice currentDevice] isPad] ? kTABLE_SECTION_HEADER_HEIGHT*1.5f : kTABLE_SECTION_HEADER_HEIGHT;
    return height50;
#else
    return 0;
#endif
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
#if kUSE_SECTION_HEADER
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
    sectionHeader.textColor = [self themeColor];
    [headerView addSubview:sectionHeader];
    sectionHeader.center = headerView.center;
    return headerView;
#else
    return nil;
#endif
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

#define kROW_NUM_REFRESH_BUTTON 6

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == kROW_NUM_REFRESH_BUTTON ) {
        return 64.0;
    }
    else {
        return 44.0;
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == kROW_NUM_REFRESH_BUTTON ) {
        NSDictionary *currentDict = [sectionsArray objectAtIndex:indexPath.row];
        id uiElement = [currentDict objectForKey:@"buttonRefreshAllData"];
        ((UIView*)uiElement).center = cell.contentView.center;
    }
    // cell.backgroundColor = kCOLOR_BLACK;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [self brighterColor];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.textColor = [self themeColor];
    }
    
    // Configure the cell...
    NSDictionary *currentDict = [sectionsArray objectAtIndex:indexPath.row];
    id uiElement = nil;
        
    switch( indexPath.row ) {

        case 0: {
            uiElement = [currentDict objectForKey:@"switchAutoUpdate"];
            cell.textLabel.text = LOC( @"Autoupdate" );
            cell.detailTextLabel.text = LOC( @"Aktualisiere alle Daten beim Start" );
            cell.accessoryView = uiElement;
            break;
        }

        case 1: {
            uiElement = [currentDict objectForKey:@"switchImageUpdates"];
            cell.textLabel.text = LOC( @"Bilderupdate" );
            cell.detailTextLabel.text = LOC( @"Aktualisiere auch alle Bilder" );
            cell.accessoryView = uiElement;
            break;
        }

        case 2: {
            uiElement = [currentDict objectForKey:@"switchFailover"];
            cell.textLabel.text = LOC( @"Failover" );
            cell.detailTextLabel.text = LOC( @"Backup-Server aktivieren" );
            cell.accessoryView = uiElement;
            break;
        }

        case 3: {
            uiElement = [currentDict objectForKey:@"switchCloudSync"];
            cell.textLabel.text = LOC( @"iCloud" );
            cell.accessoryView = uiElement;
        ((UISwitch*)uiElement).enabled = [MKiCloudSync instance].isDeviceCloudEnabled;
            if( ![[MKiCloudSync instance] hasDeviceCloudSupport] ) {
                cell.detailTextLabel.text = LOC( @"Device does not support iCloud" );
            } else if( ![[MKiCloudSync instance] isDeviceCloudEnabled] ) {
                cell.detailTextLabel.text = LOC( @"Please enable iCloud in Settings" );
            } else {
                cell.detailTextLabel.text = LOC( @"Synchronize Favourites with iCloud" );
            }
            break;
        }

        case 4: {
            uiElement = [currentDict objectForKey:@"switchTimeFocus"];
            cell.textLabel.text = LOC( @"Timefocus" );
            cell.detailTextLabel.text = LOC( @"Aktuelle Fahrplanzeit hervorheben" );
            cell.accessoryView = uiElement;
            break;
        }

        case 5:
            uiElement = [currentDict objectForKey:@"buttonForceReconfig"];
            cell.textLabel.text = LOC( @"Force Reconfigure" );
            cell.detailTextLabel.text = LOC( @"Basiskonfiguration resetten" );
            cell.accessoryView = uiElement;
            break;

        case kROW_NUM_REFRESH_BUTTON:
            uiElement = [currentDict objectForKey:@"buttonRefreshAllData"];
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentView.contentMode = UIViewContentModeCenter;
            [cell.contentView addSubview:uiElement];
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
