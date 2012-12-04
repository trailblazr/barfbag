//
//  BarfBagParser.m
//  AnyXML
//
//  Created by Helge Städtler on 16.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import "BarfBagParser.h"
#import "Conference.h"
#import "Day.h"
#import "Event.h"
#import "Person.h"

@implementation BarfBagParser

@synthesize delegate;
@synthesize conferencesParsed;
@synthesize daysParsed;
@synthesize eventsParsed;
@synthesize personsParsed;
@synthesize linksParsed;
@synthesize responseData;
@synthesize currentXmlElement;
@synthesize currentConference;
@synthesize currentDay;
@synthesize currentEvent;
@synthesize currentPerson;
@synthesize currentLink;
@synthesize currentElementKeyValues;

/*
@synthesize xmltitle;
@synthesize xmlDurationString;
@synthesize xmlstartDateTimeString;
*/
 
#pragma mark -
#pragma mark construction & destruction

- (void)dealloc {
	self.delegate = nil;
	[conferencesParsed release];
	[daysParsed release];
	[eventsParsed release];
	[personsParsed release];
	[linksParsed release];
	[responseData release];
	[currentXmlElement release];
	[currentConference release];
	[currentDay release];
	[currentEvent release];
	[currentPerson release];
	[currentLink release];
	[currentElementKeyValues release];
	[super dealloc];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
		self.conferencesParsed = [NSMutableArray array];
		self.daysParsed = [NSMutableArray array];
		self.eventsParsed = [NSMutableArray array];
		self.personsParsed = [NSMutableArray array];
		self.linksParsed = [NSMutableArray array];
		self.currentElementKeyValues = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -
#pragma mark http connection handling methods

- (void)parseXmlRssFeed:(NSString *)url withDelegate:(id)delegateToUse {
	self.delegate = delegateToUse;
	self.responseData = [NSMutableData data];
	
	NSURL *baseURL = [[NSURL URLWithString:url] retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString * errorString = [NSString stringWithFormat:@"Unable to download xml data (Error code %i )", [error code]];
	
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self startParsingResponseData];
}

- (void) startParsingResponseData {
	NSXMLParser *rssXmlParser = [[NSXMLParser alloc] initWithData:responseData];
	[rssXmlParser setDelegate:self];
	[rssXmlParser parse];
}

#pragma mark -
#pragma mark xml parsing methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if( DEBUG ) NSLog( @"BARFBAG: PARSING STARTED." );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_STARTED object:self];
	// init with fresh array
	self.daysParsed = [NSMutableArray array];
	self.eventsParsed = [NSMutableArray array];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

	self.currentXmlElement = [elementName copy];

	// CONFERENCE
	if( [elementName isEqualToString:@"conference"] ) { // init fresh conf
		self.currentConference = [[Conference alloc] init];
	}
	
	// DAY
	if( [elementName isEqualToString:@"day"] ) { // init fresh day
		self.currentDay = [[Day alloc] init];
		NSString *dayIndexString = [attributeDict objectForKey:@"index"];
		currentDay.dayIndex = [dayIndexString intValue];
		NSString *dayDateString = [attributeDict objectForKey:@"date"];
        // PARSE DATE
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"YYYY-MM-dd";
        @try {
            currentDay.date = [df dateFromString:dayDateString];
        }
        @catch (NSException *exception) {
            //
        }
        [df release];
	}
	
	// EVENT
    if( [elementName isEqualToString:@"event"] ) { // init fresh event on opening tag
		self.currentEvent = [[Event alloc] init];
		// extract id attribute
		NSString *eventIdString = [attributeDict objectForKey:@"id"];
		currentEvent.eventId = [eventIdString intValue];		
    }	

	// PERSON
    if( [elementName isEqualToString:@"person"] ) { // init fresh person on opening tag
		self.currentPerson = [[Person alloc] init];
		// extract id attribute
		NSString *personIdString = [attributeDict objectForKey:@"id"];
		currentPerson.personId = [personIdString intValue];		
    }	

	// LINK
    if( [elementName isEqualToString:@"link"] ) { // init fresh person on opening tag
		self.currentLink = [[Link alloc] init];
		// extract href attribute
		currentLink.href = [attributeDict objectForKey:@"href"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

	NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
	[self appendString:[string stringByTrimmingCharactersInSet:charsToTrim] forKey:currentXmlElement withPrefix:@"unknown"];
	/*
	else if ([currentXmlElement isEqualToString:@"pubDate"]) {
		[self.currentDate appendString:string];
		NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
		[self.currentDate setString: [self.currentDate stringByTrimmingCharactersInSet: charsToTrim]];
    }*/
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{

	// CONFERENCE
	if( [elementName isEqualToString:@"conference"] ) {
		currentConference.title = [self stringValueForKey:@"title" withPrefix:@"unknown"];
		currentConference.subtitle = [self stringValueForKey:@"subtitle" withPrefix:@"unknown"];
		currentConference.venue = [self stringValueForKey:@"venue" withPrefix:@"unknown"];
		currentConference.city = [self stringValueForKey:@"city" withPrefix:@"unknown"];
		currentConference.release = [self stringValueForKey:@"release" withPrefix:@"unknown"];
		currentConference.startDate = [self dateFromString:[self stringValueForKey:@"start" withPrefix:@"unknown"] forFormat:@"yyyy-MM-dd"];
		currentConference.endDate = [self dateFromString:[self stringValueForKey:@"end" withPrefix:@"unknown"] forFormat:@"yyyy-MM-dd"];
		// currentConference.dayChange = [self stringValueForKey:@"venue" withPrefix:@"unknown"];
		// currentConference.timeslotDuration = [self stringValueForKey:@"venue" withPrefix:@"unknown"];
		[conferencesParsed addObject:currentConference];
	}
	
	// DAY
	if( [elementName isEqualToString:@"day"] ) {
		[currentConference addDay:currentDay];
	}
	
	// EVENT
    if( [elementName isEqualToString:@"event"] ) {
        // NSLog( @"START STRING = %@", [self stringValueForKey:@"start" withPrefix:@"unknown"] );
		[currentEvent takeStartDateTimeFromString:[self stringValueForKey:@"start" withPrefix:@"unknown"]];
		[currentEvent takeDurationFromString:[self stringValueForKey:@"duration" withPrefix:@"unknown"]];
		currentEvent.room = [self stringValueForKey:@"room" withPrefix:@"unknown"];
		currentEvent.slug = [self stringValueForKey:@"slug" withPrefix:@"unknown"];
		currentEvent.title = [self stringValueForKey:@"title" withPrefix:@"unknown"];
		currentEvent.subtitle = [self stringValueForKey:@"subtitle" withPrefix:@"unknown"];
		currentEvent.track = [self stringValueForKey:@"track" withPrefix:@"unknown"];
		currentEvent.type = [self stringValueForKey:@"type" withPrefix:@"unknown"];
		currentEvent.language = [self stringValueForKey:@"language" withPrefix:@"unknown"];
		currentEvent.abstract = [self stringValueForKey:@"abstract" withPrefix:@"unknown"];
		currentEvent.descriptionText = [self stringValueForKey:@"description" withPrefix:@"unknown"];
		[currentDay addEvent:currentEvent];		
    }

	// PERSON
	if( [elementName isEqualToString:@"person"] ) {
        currentPerson.personName = [self stringValueForKey:@"person" withPrefix:@"unknown"];
		[currentEvent addPerson:currentPerson];
	}

	// LINK
	if( [elementName isEqualToString:@"link"] ) {
        currentLink.title = [self stringValueForKey:@"link" withPrefix:@"unknown"];
		[currentEvent addLink:currentLink];
	}
}

- (void) appendString:(NSString*)stringToAppend forKey:(NSString*)key withPrefix:(NSString*)prefix {
	NSString *prefixedKey = [NSString stringWithFormat:@"%@.%@", prefix, key];
	if( ![currentElementKeyValues valueForKey:prefixedKey] ) {
		[currentElementKeyValues setValue:[NSMutableString string] forKey:prefixedKey];
	}
	NSMutableString *currentString = (NSMutableString*)[currentElementKeyValues valueForKey:prefixedKey];
	[currentString appendString:stringToAppend];
}

- (NSString*) stringValueForKey:(NSString*)key withPrefix:(NSString*)prefix {
	NSString *prefixedKey = [NSString stringWithFormat:@"%@.%@", prefix, key];
	NSString *stringToTakeAway = (NSString*)[currentElementKeyValues valueForKey:prefixedKey];
	[currentElementKeyValues removeObjectForKey:prefixedKey];
	return [stringToTakeAway trimmedString];
}

- (NSDate*) dateFromString:(NSString*)string forFormat:(NSString*)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.locale = [NSLocale currentLocale];
	dateFormatter.timeZone = [NSTimeZone localTimeZone];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	dateFormatter.timeStyle = NSDateFormatterNoStyle;
	[dateFormatter setDateFormat:format]; // 2010-12-27
	NSDate *dateFound = [dateFormatter dateFromString:string];
	[dateFormatter release];
	return dateFound;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if( DEBUG ) NSLog( @"BARFBAG: PARSING FINISHED." );
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PARSER_FINISHED object:self];
	if( [delegate respondsToSelector:@selector(receivedConferences:)] )
        [delegate receivedConferences:conferencesParsed];
    else { 
        [NSException raise:NSInternalInconsistencyException
					format:@"PentaParser delegate doesn't respond to receivedConferences:"];
    }
}

@end
