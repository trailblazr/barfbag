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

- (void) dealloc {
    self.event = nil;
    self.day = nil;
    self.cellTextLabel = nil;
    self.detailHeaderViewController =nil;
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
    self.navigationItem.title = [self stringShortDayForDate:day.date];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if( !detailHeaderViewController ) {
        self.detailHeaderViewController = [[[GenericDetailViewController alloc] initWithNibName:@"GenericDetailViewController" bundle:nil] autorelease];
    }
    self.tableView.tableHeaderView = detailHeaderViewController.view;
    self.tableView.tableHeaderView.backgroundColor = [self themeColor];

    detailHeaderViewController.titleLabel.text = event.title;
    detailHeaderViewController.titleLabel.adjustsFontSizeToFitWidth = YES;
    detailHeaderViewController.titleLabel.layer.masksToBounds = NO;
    detailHeaderViewController.subtitleLabel.text = event.subtitle;
    detailHeaderViewController.timeStart.text = [NSString stringWithFormat:LOC( @"%@ Uhr" ), event.start];
    detailHeaderViewController.timeDuration.text = [NSString stringWithFormat:@"%.1f h", event.duration];
    detailHeaderViewController.roomLabel.text = event.room;
    detailHeaderViewController.dateLabel.text = @"-";
    detailHeaderViewController.languageLabel.text = event.localizedLanguageName;
    detailHeaderViewController.trackLabel.text = event.track;
    detailHeaderViewController.speakerLabel.text = event.speakerList;

    // APPLY BACKGROUND
    UIImage *gradientImage = [self imageGradientWithSize:self.tableView.tableHeaderView.bounds.size color1:[self darkerColor] color2:[self backgroundColor]];
    UIImageView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    selectedBackgroundView.contentMode = UIViewContentModeScaleToFill;
    [self.tableView.tableHeaderView insertSubview:selectedBackgroundView atIndex:0];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self textSizeNeededForString:[self eventDescriptionText]].height;
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
    CGSize textSize = [self textSizeNeededForString:[self eventDescriptionText]];
    self.cellTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, textSize.width, textSize.height-10)] autorelease];
    cellTextLabel.font = [UIFont systemFontOfSize:16.0];
    cellTextLabel.numberOfLines = 9999999999;
    cellTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cellTextLabel.backgroundColor = kCOLOR_BACK;
    cellTextLabel.textColor = [self themeColor];
    cellTextLabel.shadowColor = [[self darkerColor] colorWithAlphaComponent:0.6];
    cellTextLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    [cell.contentView addSubview:cellTextLabel];
    
    // Configure the cell...
    cellTextLabel.text = [self eventDescriptionText];
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
