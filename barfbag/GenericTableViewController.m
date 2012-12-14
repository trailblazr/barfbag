//
//  GenericTableViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "GenericTableViewController.h"
#import "AppDelegate.h"
#import "FavouriteManager.h"
#import "FavouriteItem.h"
#import "SearchableItem.h"
#import "Event.h"
#import "JSONAssembly.h"
#import "JSONWorkshop.h"
#import "ColoredAccessoryView.h"

@implementation GenericTableViewController

@synthesize hud;
@synthesize reminderObject;
@synthesize isSearching;
@synthesize isUserAllowedToSelectRow;
@synthesize searchItemsFiltered;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.hud = nil;
    self.reminderObject = nil;
    self.searchItemsFiltered = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) colorizeViewInSubviews:(NSArray*)currentSubviews {
    for( UIView *currentView in currentSubviews ) {
        if( currentView.subviews && [currentView.subviews count] > 0 ) {
            [self colorizeViewInSubviews:currentView.subviews];
        }
        else {
            if( [currentView isKindOfClass:[UITextField class]] ) {
                UITextField *textField = (UITextField*)currentView;
                textField.borderStyle = UITextBorderStyleLine;
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (NSString*) stringRepresentationMailFor:(id)item {
    if( !item ) return nil;
    NSMutableString *stringRep = [NSMutableString string];
    if( [item isKindOfClass:[Event class]] ) {
        Event *event = (Event*)item;
        [stringRep appendString:[event stringRepresentationMail]];
    }
    if( [item isKindOfClass:[JSONAssembly class]] ) {
        JSONAssembly* assembly = (JSONAssembly*)item;
        [stringRep appendString:[assembly stringRepresentationMail]];
    }
    if( [item isKindOfClass:[JSONWorkshop class]] ) {
        JSONWorkshop* workshop = (JSONWorkshop*)item;
        [stringRep appendString:[workshop stringRepresentationMail]];
    }
    if( [item isKindOfClass:[FavouriteItem class]] ) {
        FavouriteItem* favourite = (FavouriteItem*)item;
        [stringRep appendString:[favourite stringRepresentationMail]];
    }
    if( [item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSMutableDictionary class]] ) {
        NSDictionary *dictionary = (NSDictionary*)item;
        NSArray *allKeys = [dictionary allKeys];
        NSArray *sectionItems = nil;
        for( NSString* currentKey in allKeys ) {
            sectionItems = [dictionary objectForKey:currentKey];
            [stringRep appendFormat:@"<h2>%@</h2><ul>", [currentKey uppercaseString]];
            for( id currentItem in sectionItems ) {
                // TO DO: APPEND STRING REPRESENTATIONS OF ITEMS
            [stringRep appendFormat:@"<li>"];
            [stringRep appendString:[self stringRepresentationMailFor:currentItem]]; // WARNING: RECURSIVE
            [stringRep appendFormat:@"</li>"];
            }
            [stringRep appendFormat:@"</ul>"];
        }
    }
    return stringRep;
}

- (BOOL) willExceed140CharsForString:(NSString*)strExists whenAddingString:(NSString*)strToAdd {
    return( [strExists length] + [strToAdd length] > 140 );
}

- (NSString*) stringRepresentationTwitterFor:(id)item {
    if( !item ) return @"";
    NSMutableString *stringRep = [NSMutableString string];
    if( [item isKindOfClass:[Event class]] ) {
        Event *event = (Event*)item;
        [stringRep appendString:[event stringRepresentationTwitter]];
    }
    else if( [item isKindOfClass:[JSONAssembly class]] ) {
        JSONAssembly* assembly = (JSONAssembly*)item;
        [stringRep appendString:[assembly stringRepresentationTwitter]];
    }
    else if( [item isKindOfClass:[JSONWorkshop class]] ) {
        JSONWorkshop* workshop = (JSONWorkshop*)item;
        [stringRep appendString:[workshop stringRepresentationTwitter]];
    } else if( [item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSMutableDictionary class]] ) {
        NSDictionary *dictionary = (NSDictionary*)item;
        NSArray *allEntries = [dictionary allValues];
        for( NSArray* sectionItems in allEntries ) {
            [stringRep appendFormat:@"\n\n"];
            for( id currentItem in sectionItems ) {
                // TO DO: APPEND STRING REPRESENTATIONS OF ITEMS
                NSString *recursiveRep = [self stringRepresentationTwitterFor:currentItem];
                if( recursiveRep && [recursiveRep length] > 0 ) {
                    [stringRep appendString:recursiveRep]; // WARNING: RECURSIVE
                }
            }
        }
    }
    return stringRep;
}

#pragma mark - Create Twitter Tweet

- (void) actionTweetShortenedString:(NSString*)shortenedString {
    NSMutableString *tweetText = [NSMutableString string];    
    [tweetText appendString:shortenedString];
    [tweetText appendString:@" #29c3"];
    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:tweetText];
    [tweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissModalViewControllerAnimated:YES];
            if (result == TWTweetComposeViewControllerResultDone) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Tweet erfolgreich abgesendet." delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
                [alert show];
                [alert release];
            }
        });
    }];
    [self presentViewController:tweetComposeViewController
                       animated:YES
                     completion:^{
                         
                         // do cleanup
                         
                     }];
    [tweetComposeViewController release];
}

- (void) actionShareObjectViaTwitter:(id)objectToShare {
    NSLog( @"SHARE VIA TWITTER");
    if( ![TWTweetComposeViewController canSendTweet] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Twitter", nil ) message:NSLocalizedString(@"Kein Twitter Account konfiguriert.", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
        return;
    }
    else {
        // TO DO: ensure short string limited to 140 chars
        NSString* message = [self stringRepresentationTwitterFor:objectToShare];
        [self actionTweetShortenedString:[NSString placeHolder:LOC( @"Keine Info." ) forEmptyString:message]];
    }
}

#pragma mark - Create Mail Message

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// [self becomeFirstResponder];
	[controller setDelegate:nil];
	[[self navigationController] dismissModalViewControllerAnimated:YES];
	switch (result) {
		case MFMailComposeResultCancelled: {
            BOOL shouldSHowAlert = NO;
            if( shouldSHowAlert ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Versenden der E-Mail wurde unterbrochen/abgebrochen!" delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
                [alert show];
                [alert release];
            }
			break;
        }
            
		case MFMailComposeResultSaved: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Mail wurde für späteren Versand gespeichert!" delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
            [alert show];
            [alert release];
			break;
        }
		case MFMailComposeResultSent: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Mail wurde versendet!" delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
            [alert show];
            [alert release];
			break;
        }
            
		case MFMailComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Versand fehlgeschlagen!" delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
            [alert show];
            [alert release];
			break;
        }
            
		default:
			break;
	}
}

- (NSString*) htmlMailBodyForObject:(id)object {
    NSMutableString *htmlString = [NSMutableString string];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    
    [htmlString appendFormat:@"<html><body>"];
    [htmlString appendFormat:@"<p><strong>29c3 Favorit(en):</strong></p>"];
    [htmlString appendString:@"<p>"];
    
    [htmlString appendString:[NSString placeHolder:LOC( @"Keine Informtion" ) forEmptyString:[self stringRepresentationMailFor:object]]];

    [htmlString appendString:@"</p>"];
    [htmlString appendString:@"</body></html>"];
    [df release];
    return htmlString;
}

- (void) actionShareObjectViaMail:(id)objectToShare {
    NSLog( @"SHARE VIA MAIL");
    if ( ![MFMailComposeViewController canSendMail] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Sie haben derzeit keinen E-Mail-Account auf ihrem Gerät konfiguriert. Bitte zunächst das Mail App in Betrieb nehmen!" delegate:nil cancelButtonTitle:nil otherButtonTitles:LOC( @"OK" ), nil];
        [alert show];
        [alert release];
        return;
    }
    NSArray* toRecipients = [NSArray array];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:toRecipients];
    [controller setSubject:LOC(@"29c3 Veranstaltungstipp")];
    NSString *message = [self htmlMailBodyForObject:objectToShare];
    [controller setMessageBody:message isHTML:YES];
    [[self navigationController] presentModalViewController:controller animated:YES];
    [controller.navigationBar setTintColor:kCOLOR_BACK];
    [controller release];
}

#pragma mark - Action Sheet Handling

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch( actionSheet.tag ) {
        case kACTION_SHEET_TAG_REMINDER: {
            if( !reminderObject ) return;
            if( buttonIndex == actionSheet.cancelButtonIndex ) {
                // do nothing
            }
            if( buttonIndex == actionSheet.destructiveButtonIndex ) {
                // remove
                BOOL removedSuccess = [[FavouriteManager sharedManager] favouriteRemoved:reminderObject];
                NSLog( @"REMOVED: %@", removedSuccess ? @"YES" : @"NO" );
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex ) { // MAIL
                [self actionShareObjectViaMail:reminderObject];
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex+1 ) { // TWEET
                [self actionShareObjectViaTwitter:reminderObject];
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex+2 ) {
                // add/remind me
                BOOL addedSuccess = [[FavouriteManager sharedManager] favouriteAdded:reminderObject];
                NSLog( @"ADDED: %@", addedSuccess ? @"YES" : @"NO" );
            }
            break;
        }

        case kACTION_SHEET_TAG_SHARING: {
            if( !reminderObject ) return;
            if( buttonIndex == actionSheet.cancelButtonIndex ) {
                // do nothing
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex ) { // MAIL
                [self actionShareObjectViaMail:reminderObject];
            }
            if( buttonIndex == actionSheet.firstOtherButtonIndex+1 ) { // TWEET
                [self actionShareObjectViaTwitter:reminderObject];
            }
            break;
        }

        default:
            break;
    }
}

- (void) presentActionSheetSharinOnlyForObject:(id)objectInProgress fromBarButtonItem:(UIBarButtonItem*)item {
    self.reminderObject = objectInProgress;
    NSString *titelString = [NSString stringWithFormat:@"Information für\n%@\nweitersagen?", [[FavouriteManager sharedManager] favouriteNameFromItem:reminderObject]];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:titelString delegate:self cancelButtonTitle:LOC( @"Abbrechen" ) destructiveButtonTitle:nil otherButtonTitles:LOC( @"E-Mail" ),LOC( @"Twitter" ), nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.tag = kACTION_SHEET_TAG_SHARING;
    [sheet showFromBarButtonItem:item animated:YES];
    [sheet release];
}

- (void) presentActionSheetForObject:(id)objectInProgress fromBarButtonItem:(UIBarButtonItem*)item {
    self.reminderObject = objectInProgress;
    BOOL hasAlreadyReminder = [[FavouriteManager sharedManager] hasStoredFavourite:reminderObject];
    
    NSString *titelString = nil;
    if( hasAlreadyReminder ) {
        titelString = [NSString stringWithFormat:@"Erinnerung für\n%@", [[FavouriteManager sharedManager] favouriteNameFromItem:reminderObject]];
    }
    else {
        titelString = [NSString stringWithFormat:@"Erinnerung für\n%@", [[FavouriteManager sharedManager] favouriteNameFromItem:reminderObject]];
    }
    NSString* destructionTitle = hasAlreadyReminder ? LOC( @"Entfernen" ) : nil;
    NSString* reminderTitle = hasAlreadyReminder ? nil : LOC( @"Vormerken" );
    NSString* sharingMail = LOC( @"E-Mailen" );
    NSString* sharingTwitter = LOC( @"Twittern" );
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:titelString delegate:self cancelButtonTitle:LOC( @"Abbrechen" ) destructiveButtonTitle:destructionTitle otherButtonTitles:sharingMail,sharingTwitter,reminderTitle, nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.tag = kACTION_SHEET_TAG_REMINDER;
    [sheet showFromBarButtonItem:item animated:YES];
    [sheet release];
}

- (IBAction) actionMultiActionButtonTapped:(id)sender {
    
}

- (IBAction) actionMultiActionSharingOnlyButtonTapped:(id)sender {
    
}

- (UIBarButtonItem*) actionBarButtonItemSharingOnly {
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMultiActionSharingOnlyButtonTapped:)] autorelease];
    return item;
}

- (UIBarButtonItem*) actionBarButtonItem {
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMultiActionButtonTapped:)] autorelease];
    return item;
}

- (void) refreshVisibleCells {
    NSArray *visibleIndexPaths = self.tableView.indexPathsForVisibleRows;
    [self.tableView reloadRowsAtIndexPaths:visibleIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVisibleCells) name:kNOTIFICATION_FAVOURITE_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVisibleCells) name:kNOTIFICATION_FAVOURITE_REMOVED object:nil];

    self.isSearching = NO;
    self.isUserAllowedToSelectRow = NO;
    self.searchItemsFiltered = [NSMutableArray array];

    self.view.backgroundColor = [self backgroundColor];
    self.tableView.separatorColor = [self darkColor];
    self.tableView.backgroundView = nil;

    // APPLY SOME NICE SEARCHBAR HACK
    UISearchBar *sb = self.searchDisplayController.searchBar;
    for (UIView *subview in sb.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }

    // [self colorizeViewInSubviews:sb.subviews];
    
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

- (Conference*) conference {
    return (Conference*)[[self appDelegate].scheduledConferences lastObject];
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
    return [self stringForDate:date withFormat:@"eee, dd.MM.yyyy @ HH:mm"];
}

- (NSString*) stringDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eeee"];
}

- (NSString*) stringShortDayForDate:(NSDate*)date {
    if( !date ) return nil;
    return [self stringDayForDate:date withDayFormat:@"eee"];
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

- (CGSize) textSizeNeededForString:(NSString*)textToDisplay {
    CGFloat font16 = [[UIDevice currentDevice] isPad] ? 32.0f : 16.0f;
    CGFloat offset10 = [[UIDevice currentDevice] isPad] ? 20.0f : 10.0f;
    CGSize sizeForText = [textToDisplay sizeWithFont:[UIFont systemFontOfSize:font16] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width-offset10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(sizeForText.width, sizeForText.height+50.0);
}

- (UILabel*) cellTextLabelWithRect:(CGRect)rect {
    CGFloat font16 = [[UIDevice currentDevice] isPad] ? 32.0f : 16.0f;
    UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
    label.font = [UIFont systemFontOfSize:font16];
    label.numberOfLines = 9999999999;
    label.contentMode = UIViewContentModeTop;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = kCOLOR_BACK;
    label.textColor = [self themeColor];
    label.shadowColor = [[self darkerColor] colorWithAlphaComponent:0.3];
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    return label;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.contentMode = UIViewContentModeTop;
    CGRect contentViewRect = cell.contentView.frame;
    CGFloat offset5 = [[UIDevice currentDevice] isPad] ? 10.0f : 5.0f;
    ((UIView*)[cell.contentView.subviews lastObject]).frame = CGRectMake(contentViewRect.origin.x+offset5, contentViewRect.origin.y, contentViewRect.size.width-(2.0*offset5), contentViewRect.size.height);
    [cell setNeedsLayout];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    return height20;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height20 = [[UIDevice currentDevice] isPad] ? 40.0f : 20.0f;
    CGFloat fontSize16 = [[UIDevice currentDevice] isPad] ? 32.0f : 16.0f;
    CGRect containerRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, height20);
    UIView *containerView = [[[UIView alloc] initWithFrame:containerRect] autorelease];
    containerView.opaque = NO;
    containerView.backgroundColor = [[self themeColor] colorWithAlphaComponent:0.9f];
    CGFloat offset5 = [[UIDevice currentDevice] isPad] ? 10.0f : 5.0f;
    CGRect labelRect = CGRectMake(offset5, 0.0, containerRect.size.width-(2*offset5), containerRect.size.height);
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

#pragma mark - UISearchBarDelegate, UISearchDisplayDelegate

- (NSArray*) allSearchableItems {
    // ATTN: NEEDS TO BE OVERRIDDEN IN SUBCLASS TO HAVE SEARCH WORKING
    return nil;
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return NO;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    self.isSearching = YES;
    self.isUserAllowedToSelectRow = NO;
    self.tableView.scrollEnabled = NO;
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {

    // CLEAN FILTERED ARRAY
    [searchItemsFiltered removeAllObjects];
    
    // ADJUST/PREPARE UI
    BOOL hasEnteredSubstantialSearchString = ( [searchText length] > 0 );
    self.isSearching = hasEnteredSubstantialSearchString;
    self.isUserAllowedToSelectRow = hasEnteredSubstantialSearchString;
    self.tableView.scrollEnabled = hasEnteredSubstantialSearchString;

    // TRIGGER FILTERING
    if( hasEnteredSubstantialSearchString ) {
        [self searchTableView];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self searchTableView];
}

- (void) searchTableView {
    NSString *searchText = self.searchDisplayController.searchBar.text;
    NSArray *items = [self allSearchableItems];

    // FILTER CERTAIN PROPERTIES
    for( id currentItem in items ) {
        SearchableItem *searchableItem = (SearchableItem*)currentItem;
        NSRange resultsRangeTitle = [searchableItem.itemTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange resultsRangeSubTitle = [searchableItem.itemSubtitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange resultsRangeAbstract = [searchableItem.itemAbstract rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSRange resultsRangePerson = [searchableItem.itemPerson rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if( resultsRangeTitle.length > 0 ||
           resultsRangeSubTitle.length > 0 ||
           resultsRangeAbstract.length > 0 ||
           resultsRangePerson.length > 0 ) {
            [searchItemsFiltered addObject:currentItem];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemDateStart" ascending:TRUE];
    [searchItemsFiltered sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    [self.tableView reloadData];    
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchDisplayController.searchBar.text = @"";
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    self.isSearching = NO;
    self.isUserAllowedToSelectRow = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.tableView reloadData];
}

- (void) loadSimpleWebViewWithURL:(NSURL*)url shouldScaleToFit:(BOOL)shouldScaleToFit {
    // LOAD WEBVIEW
    WebbrowserViewController *controller = [[WebbrowserViewController alloc] initWithNibName:@"WebbrowserViewController" bundle:nil];
    controller.urlToOpen = url;
    controller.shouldScaleToFit = shouldScaleToFit;
    controller.delegate = (id<WebbrowserViewControllerDelegate>)self; // ISSUES WITH DELEGATE INHERITANCE
    controller.shouldDetectPages404 = YES;
    [self.navigationController presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) webcontentViewControllerDidFinish:(WebbrowserViewController*)controller {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
