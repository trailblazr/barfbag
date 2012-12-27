//
//  EventDetailViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 09.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "EventDetailViewController.h"
#import "AppDelegate.h"

@implementation EventDetailViewController

@synthesize event;
@synthesize day;
@synthesize cellTextLabel;
@synthesize detailHeaderViewController;
@synthesize sectionKeys;
@synthesize sectionArrays;

- (void) dealloc {
    self.event = nil;
    self.day = nil;
    self.cellTextLabel = nil;
    self.detailHeaderViewController = nil;
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

- (IBAction) actionMultiActionButtonTapped:(UIBarButtonItem*)item {
    [self presentActionSheetForObject:event fromBarButtonItem:item];
}

- (void) actionOpenWebPage {
    NSString* urlString = event.websiteHref;
    NSURL *url = [NSURL URLWithString:urlString];
    [self loadSimpleWebViewWithURL:url shouldScaleToFit:YES];
}

- (void) setupTableViewFooter {
    CGFloat width = self.tableView.frame.size.width;
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 70.0)] autorelease];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerView.backgroundColor = [self themeColor];
    UIButton *buttonOpenWiki = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 40.0)];
    [buttonOpenWiki addTarget:self action:@selector(actionOpenWebPage) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:buttonOpenWiki];
    [buttonOpenWiki setTitle:LOC( @"Webseite öffnen" ) forState:UIControlStateNormal];
    [buttonOpenWiki.titleLabel setFont:[UIFont boldSystemFontOfSize:buttonOpenWiki.titleLabel.font.pointSize]];
    [buttonOpenWiki setTitleColor:kCOLOR_WHITE forState:UIControlStateNormal];
    buttonOpenWiki.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    buttonOpenWiki.center = footerView.center;
    self.tableView.tableFooterView = footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self stringShortDayForDate:day.date];
    self.navigationItem.rightBarButtonItem = [self actionBarButtonItem];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if( !detailHeaderViewController ) {
        self.detailHeaderViewController = [[[GenericDetailViewController alloc] initWithNibName:@"GenericDetailViewController" bundle:nil] autorelease];
    }
    self.tableView.tableHeaderView = detailHeaderViewController.view;
    self.tableView.tableHeaderView.backgroundColor = [self themeColor];

    [self setupTableViewFooter];
    
    detailHeaderViewController.titleLabel.text = event.title;
    detailHeaderViewController.titleLabel.adjustsFontSizeToFitWidth = YES;
    detailHeaderViewController.titleLabel.layer.masksToBounds = NO;
    detailHeaderViewController.subtitleLabel.text = event.subtitle;
    detailHeaderViewController.timeStart.text = [self stringTimeForDate:event.itemDateStart];
    detailHeaderViewController.timeDuration.text = event.durationString;
    detailHeaderViewController.roomLabel.text = event.room;
    detailHeaderViewController.dateLabel.text = @"-";
    detailHeaderViewController.languageLabel.text = event.localizedLanguageName;
    detailHeaderViewController.trackLabel.text = event.track;
    detailHeaderViewController.speakerLabel.text = event.speakerList;

    // SETUP SECTION ORDER
    self.sectionKeys = [NSArray arrayWithObjects:
                        @"descriptionText",
                        @"persons",
                        @"links",
                        nil];
    
    // SETUP DATA
    self.sectionArrays = [NSMutableDictionary dictionary];
    NSMutableArray *neededSectionKeys = [NSMutableArray array];
    
    // DESCRIPTION
    [neededSectionKeys addObject:@"descriptionText"];
    [sectionArrays setObject:[NSArray arrayWithObject:[self eventDescriptionText]] forKey:@"descriptionText"];
    // PERSONS
    if( event.persons && [event.persons count] > 0 ) {
        [neededSectionKeys addObject:@"persons"];
        [sectionArrays setObject:[NSArray arrayWithArray:event.persons] forKey:@"persons"];
    }
    // LINKS
    if( event.links && [event.links count] > 0 ) {
        [neededSectionKeys addObject:@"links"];
        [sectionArrays setObject:[NSArray arrayWithArray:event.links] forKey:@"links"];
    }

    self.sectionKeys = [NSArray arrayWithArray:neededSectionKeys];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) eventDescriptionText {
    return [NSString placeHolder:LOC( @"Keine Beschreibung vorhanden." ) forEmptyString:event.descriptionText];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch( indexPath.section ) {
        case 0:
            return [self textSizeNeededForString:[self eventDescriptionText]].height;
            break;
            
        default:
            break;
    }
    return 50.0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
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

    // clean existing cell
    while( [cell.contentView.subviews count] > 0 ) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    if( [sectionKey isEqualToString:@"descriptionText"] ) {
        CGSize textSize = [self textSizeNeededForString:[self eventDescriptionText]];
        CGFloat offset5 = [[UIDevice currentDevice] isPad] ? 10.0f : 5.0f;
        self.cellTextLabel = [self cellTextLabelWithRect:CGRectMake(offset5, 0.0, textSize.width-(2.0*offset5), textSize.height)];
        [cell.contentView addSubview:cellTextLabel];
        cellTextLabel.text = [self eventDescriptionText];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if( [sectionKey isEqualToString:@"persons"] ) {
        Person *currentPerson = (Person*)[items objectAtIndex:indexPath.row];
        cell.textLabel.text = currentPerson.personName;
        cell.detailTextLabel.text = currentPerson.personIdKey;
        cell.imageView.image = [currentPerson cachedImage];

        /*
        UIImageView *personImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
        personImageView.backgroundColor = [self darkColor];
        personImageView.contentMode = UIViewContentModeScaleAspectFill;
        personImageView.layer.cornerRadius = 7.0;
        personImageView.layer.masksToBounds = YES;
        personImageView.layer.borderColor = [[self darkerColor] colorWithAlphaComponent:0.3].CGColor;
        personImageView.layer.borderWidth = 1.0;
         cell.accessoryView = personImageView;
         */
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if( [sectionKey isEqualToString:@"links"] ) {
        Link *currentLink = (Link*)[items objectAtIndex:indexPath.row];
        cell.textLabel.text = currentLink.title;
        cell.detailTextLabel.text = [currentLink.href httpUrlString];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = [ColoredAccessoryView disclosureIndicatorViewWithColor:[self themeColor]];
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
    if( [[sectionKeys objectAtIndex:indexPath.section] isEqualToString:@"persons"] ) {
        NSLog( @"TOUCHED PERSON" );
        NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
        Person *currentPerson = (Person*)[[sectionArrays objectForKey:sectionKey] objectAtIndex:indexPath.row];
        if( currentPerson.websiteHref ) {
            NSURL *linkUrl = [NSURL URLWithString:[currentPerson.websiteHref httpUrlString]];
            [self loadSimpleWebViewWithURL:linkUrl shouldScaleToFit:YES];
        }
    }
    if( [[sectionKeys objectAtIndex:indexPath.section] isEqualToString:@"links"] ) {
        NSLog( @"TOUCHED LINK" );
        NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
        Link *currentLink = (Link*)[[sectionArrays objectForKey:sectionKey] objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:[currentLink.href httpUrlString]];
        [self loadSimpleWebViewWithURL:url shouldScaleToFit:YES];
    }

    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
