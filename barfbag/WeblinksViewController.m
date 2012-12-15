//
//  WeblinksViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 15.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "WeblinksViewController.h"
#import "MasterConfig.h"

@implementation WeblinksViewController

@synthesize sectionKeys;
@synthesize sectionArrays;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.sectionKeys = nil;
    self.sectionArrays = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) actionUpdateDisplayAfterRefresh {
    // SETUP SECTION ORDER
    self.sectionKeys = [NSArray arrayWithObjects:
                        @"livestream",
                        @"livestreamtest",
                        @"otherlinks",
                        nil];
    
    // SETUP DATA
    self.sectionArrays = [NSMutableDictionary dictionary];
    NSMutableArray *neededSectionKeys = [NSMutableArray array];
    
    // ADD FROM MASTER CONFIG
    NSArray *entryDictionaries = [MasterConfig sharedConfiguration].configWeblinkArray;
    
    if( entryDictionaries && [entryDictionaries count] > 0 ) {
        for( NSDictionary *currentEntryDict in entryDictionaries ) {
            NSString *sectionGroupKey = [currentEntryDict objectForKey:@"groupKey"];
            NSMutableArray *sectionEntries = [sectionArrays objectForKey:sectionGroupKey];
            if( !sectionEntries ) {
                [neededSectionKeys addObject:sectionGroupKey];
                sectionEntries = [NSMutableArray array];
                [sectionArrays setObject:sectionEntries forKey:sectionGroupKey];
            }
            [sectionEntries addObject:currentEntryDict]; // ADD DICTIONARY FOR ROW-ENTRY
        }
    }
    self.sectionKeys = [NSArray arrayWithArray:neededSectionKeys];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionUpdateDisplayAfterRefresh) name:kNOTIFICATION_PARSER_COMPLETED  object:nil];
    self.navigationItem.title = LOC( @"29C3 Livestreams" );
    
    [self actionUpdateDisplayAfterRefresh];
    
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

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    return LOC( sectionKey );
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSArray *itemsInSection = [sectionArrays objectForKey:sectionKey];
    return [itemsInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = kCOLOR_BACK;
        cell.textLabel.textColor = [self brighterColor];
        cell.detailTextLabel.textColor = [self themeColor];
        cell.textLabel.backgroundColor = kCOLOR_CLEAR;
        cell.detailTextLabel.backgroundColor = kCOLOR_CLEAR;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        backgroundView.backgroundColor = [self backgroundColor];
        cell.backgroundView = backgroundView;
        UIImage *gradientImage = [self imageGradientWithSize:cell.bounds.size color1:[self themeColor] color2:[self darkerColor]];
        UIView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        selectedBackgroundView.backgroundColor = [self darkColor];
        cell.selectedBackgroundView = selectedBackgroundView;
    }
    
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *items = [sectionArrays objectForKey:sectionKey];
    NSDictionary *currentEntryDict = [items objectAtIndex:indexPath.row];
    
    // clean existing cell
    while( [cell.contentView.subviews count] > 0 ) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    cell.accessoryView = [ColoredAccessoryView disclosureIndicatorViewWithColor:[self themeColor]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
    cell.textLabel.text = [currentEntryDict objectForKey:@"itemTitleDe"];
    cell.detailTextLabel.text = [currentEntryDict objectForKey:@"itemSubtitleDe"];
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
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *items = [sectionArrays objectForKey:sectionKey];
    NSDictionary *currentEntryDict = [items objectAtIndex:indexPath.row];
    
    NSString *urlStringToOpen = [currentEntryDict objectForKey:@"itemUrl"];
    
    NSURL *url = [NSURL URLWithString:[urlStringToOpen httpUrlString]];
    BOOL isFon = ![[UIDevice currentDevice] isPad];
    [self loadSimpleWebViewWithURL:url shouldScaleToFit:YES isModal:isFon];
}

@end
