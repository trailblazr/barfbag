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
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize timeStart;
@synthesize timeDuration;
@synthesize roomLabel;
@synthesize dateLabel;
@synthesize languageLabel;
@synthesize trackLabel;
@synthesize speakerLabel;
@synthesize cellTextLabel;

- (void) dealloc {
    self.event = nil;
    self.day = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.timeStart = nil;
    self.timeDuration = nil;
    self.roomLabel = nil;
    self.dateLabel = nil;
    self.languageLabel = nil;
    self.trackLabel = nil;
    self.speakerLabel = nil;
    self.cellTextLabel = nil;
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
    self.tableView.tableHeaderView.backgroundColor = [self themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // APPLY BACKGROUND
    UIImage *gradientImage = [self imageGradientWithSize:self.tableView.tableHeaderView.bounds.size color1:[self darkerColor] color2:[self backgroundColor]];
    UIImageView *selectedBackgroundView = [[[UIImageView alloc] initWithImage:gradientImage] autorelease];
    [self.tableView.tableHeaderView insertSubview:selectedBackgroundView atIndex:0];
    titleLabel.text = event.title;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.layer.masksToBounds = NO;
    subtitleLabel.text = event.subtitle;
    timeStart.text = [NSString stringWithFormat:LOC( @"%@ Uhr" ), event.start];
    timeDuration.text = [NSString stringWithFormat:@"%.1f h", event.duration];
    roomLabel.text = event.room;
    dateLabel.text = @"-";
    languageLabel.text = event.localizedLanguageName;
    trackLabel.text = event.track;
    speakerLabel.text = event.speakerList;
    
    NSArray *labelArray = [NSArray arrayWithObjects:titleLabel,subtitleLabel,timeStart,timeDuration,roomLabel,dateLabel,languageLabel,trackLabel,speakerLabel,nil];
    for( UILabel *currentLabel in labelArray ) {
        currentLabel.textColor = [self brighterColor];
        currentLabel.shadowColor = [[self darkColor] colorWithAlphaComponent:0.8];
        currentLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    }

    
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
    return 1;
}

- (CGSize) textSize {
    NSString* textToDisplay = [NSString placeHolder:LOC( @"Keine Beschreibung vorhanden." ) forEmptyString:event.descriptionText];
    CGSize sizeForText = [textToDisplay sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width-10.0, 999999999.0) lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(sizeForText.width, sizeForText.height+50.0);
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self textSize].height;
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
    CGSize textSize = [self textSize];
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
    cellTextLabel.text = [NSString placeHolder:LOC( @"Keine Beschreibung vorhanden." ) forEmptyString:event.descriptionText];
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
