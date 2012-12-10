//
//  GenericTableViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "GenericTableViewController.h"
#import "AppDelegate.h"

@implementation GenericTableViewController

@synthesize hud;

- (void) dealloc {
    self.hud = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self backgroundColor];
    self.tableView.separatorColor = [self darkColor];
    self.tableView.backgroundView = nil;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (NSString*) stringForDate:(NSDate*)date withFormat:(NSString*)format {
    if( !date ) return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = format;
    NSString *formattedDate = [df stringFromDate:date];
    [df release];
    return formattedDate;
}


- (NSString*) stringDayForDate:(NSDate*)date withDayFormat:(NSString*)dayFormat {
    if( !date ) return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    df.dateFormat = [NSString stringWithFormat:@"%@, %@", dayFormat, df.dateFormat];
    NSString *formattedDate = [df stringFromDate:date];
    [df release];
    return formattedDate;
}

- (NSString*) stringTimeForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringForDate:date withFormat:@"eee, dd. @ HH:mm"];
}

- (NSString*) stringDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eeee"];
}

- (NSString*) stringShortDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eee"];
}

- (UILabel*) cellTextLabelWithRect:(CGRect)rect {
    UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
    label.font = [UIFont systemFontOfSize:16.0];
    label.numberOfLines = 9999999999;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = kCOLOR_BACK;
    label.textColor = [self themeColor];
    label.shadowColor = [[self darkerColor] colorWithAlphaComponent:0.3];
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    return label;
}

#pragma mark - Colors

- (UIColor*) backgroundColor {
    return [self appDelegate].backgroundColor;
}

- (UIColor*) themeColor {
    return [self appDelegate].themeColor;
}

- (UIColor*) brightColor {
    return [self appDelegate].brightColor;
}

- (UIColor*) brighterColor {
    return [self appDelegate].brighterColor;
}

- (UIColor*) darkColor {
    return [self appDelegate].darkColor;
}

- (UIColor*) darkerColor {
    return [self appDelegate].darkerColor;
}

- (CGSize) textSizeNeededForString:(NSString*)textToDisplay {
    CGSize sizeForText = [textToDisplay sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width-10.0, 999999999.0) lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(sizeForText.width, sizeForText.height+50.0);
}

- (UIImage*) imageGradientWithSize:(CGSize)imageSize color1:(UIColor*)color1 color2:(UIColor*)color2 {
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else {
        UIGraphicsBeginImageContext(imageSize);
    }
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(c);
    
    // draw gradient
	CGGradientRef gradient;
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[2] = { 0.0, 1.0 };
    
	// step 3: define gradient with components
	CGFloat colors[] = {
        [color1 red],[color1 green],[color1 blue],[color1 alpha],
        [color2 red],[color2 green],[color2 blue],[color2 alpha]
	};
    
    gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, sizeof(colors)/(sizeof(colors[0])*4));
	//gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	// gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 0);
	
	CGPoint start, end;
	start = CGPointMake( 0.0, 0.0 );
	end = CGPointMake( 0.0, imageSize.height );
    CGContextClearRect(c, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height) );
	CGContextDrawLinearGradient(c, gradient, start, end, 0);
	
	// release c-stuff
	CGColorSpaceRelease(rgb);
	CGGradientRelease(gradient);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(c);
    
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Headup Display Management

- (void) showHudWithCaption:(NSString*)caption hasActivity:(BOOL)hasActivity {
    // ADD HUD VIEW
    if( !hud ) {
        self.hud = [[ATMHud alloc] initWithDelegate:self];
        [self.view addSubview:hud.view];
    }
    [hud setCaption:caption];
    [hud setActivity:hasActivity];
    [hud show];
}

- (void) hideHud {
    [hud hide];
}

- (void) userDidTapHud:(ATMHud *)_hud {
	[_hud hide];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    CGFloat fontSize16 = [[UIDevice currentDevice] isPad] ? 32.0f : 16.0f;
    CGRect containerRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, height20);
    UIView *containerView = [[[UIView alloc] initWithFrame:containerRect] autorelease];
    containerView.opaque = NO;
    containerView.backgroundColor = [[self themeColor] colorWithAlphaComponent:0.9f];
    CGFloat offset = 10.0f;
    CGRect labelRect = CGRectMake(offset, 0.0, containerRect.size.width-(2*offset), containerRect.size.height);
    UILabel *label = [[[UILabel alloc] initWithFrame:labelRect] autorelease];
    [containerView addSubview:label];
    label.backgroundColor = kCOLOR_CLEAR;
    label.font = [UIFont boldSystemFontOfSize:fontSize16];
    label.textColor = kCOLOR_WHITE;
    label.shadowColor = [kCOLOR_BLACK colorWithAlphaComponent:0.5];
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    return containerView;
}

@end
