//
//  Event.m
//  AnyXML
//
//  Created by Helge Städtler on 26.12.10.
//  Copyright 2010 staedtler development. All rights reserved.
//

#import "Event.h"
#import "Day.h"
#import "RegexKitLite.h"
#import "MasterConfig.h"
#import "NSString-Toolkit.h"
#import "FavouriteManager.h"

@implementation Event

@synthesize eventId;
@synthesize duration;
@synthesize start;
@synthesize timeHour;
@synthesize timeMinute;
@synthesize type;
@synthesize room;
@synthesize slug;
@synthesize title;	
@synthesize subtitle;
@synthesize track;
@synthesize language;
@synthesize abstract;
@synthesize descriptionText;
@synthesize persons;
@synthesize links;
@synthesize dateStart;
@synthesize dateEnd;
@synthesize day;


- (void) dealloc {
	[start release];
	[room release];
	[slug release];
	[title release];
	[subtitle release];
	[track release];
	[language release];
	[abstract release];
	[descriptionText release];
	[persons release];
	[links release];
    self.dateStart = nil;
    self.dateEnd = nil;
    self.day = nil;
	[super dealloc];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
		self.eventId = -1;
		self.title = @"Unknown";
        self.persons = [NSMutableArray array];
        self.links = [NSMutableArray array];
    }
    return self;
}

- (NSString*) imageName {
    return [NSString stringWithFormat:@"event-%i-128x128.png", eventId];
}

- (NSString*) pngIconHref {
    NSString *imageTemplateUrl = [[MasterConfig sharedConfiguration] urlStringForKey:kURL_KEY_29C3_EVENT_IMG];
    imageTemplateUrl = [imageTemplateUrl stringByReplacingOccurrencesOfString:@"$id$" withString:[self eventIdKey]];
    return imageTemplateUrl;
}

- (NSString*) websiteHref {
    NSString *imageTemplateUrl = [[MasterConfig sharedConfiguration] urlStringForKey:kURL_KEY_29C3_EVENT_SITE];
    imageTemplateUrl = [imageTemplateUrl stringByReplacingOccurrencesOfString:@"$id$" withString:[self eventIdKey]];
    return imageTemplateUrl;
}

- (NSString*) eventIdKey {
    return [NSString stringWithFormat:@"%i", eventId];
}

- (void) addPerson:(Person*)personToAdd {
    [persons addObject:personToAdd];
}

- (void) addLink:(Link*)linkToAdd {
    [links addObject:linkToAdd];
}

- (NSString*) localizedLanguageName {
    return LOC( self.language );
}

- (NSString*) speakerList {
    NSMutableString *listString = [NSMutableString string];
    for( Person *currentPerson in [self persons] ) {
        BOOL needsComma = ( [listString length] > 0 );
        [listString appendFormat:@"%@%@", needsComma ? @", " : @"", currentPerson.personName];
    }
    return listString;
}

- (NSString*) description {
	NSMutableString *stringRepresentation = [NSMutableString string];
	[stringRepresentation appendFormat:@"EVENT (%i)\n", eventId];
	[stringRepresentation appendFormat:@"title = %@\n", title == nil ? @"[NIL]" : title];
	[stringRepresentation appendFormat:@"subtitle = %@\n", subtitle == nil ? @"[NIL]" : subtitle];
	[stringRepresentation appendFormat:@"room = %@\n", room == nil ? @"[NIL]" : room];
	[stringRepresentation appendFormat:@"track = %@\n", track == nil ? @"[NIL]" : track];
	[stringRepresentation appendFormat:@"language = %@\n", language == nil ? @"[NIL]" : language];
	[stringRepresentation appendFormat:@"room = %@\n", room == nil ? @"[NIL]" : room];
	[stringRepresentation appendFormat:@"start = %@\n", start == nil ? @"[NIL]" : start];
	[stringRepresentation appendFormat:@"duration = %f\n", duration == 0 ? -1.0f : duration];
	[stringRepresentation appendFormat:@"icon = %@\n", [self pngIconHref]];
	[stringRepresentation appendFormat:@"persons:\n%@", [persons count] ? persons : @"[NONE]"];
	[stringRepresentation appendFormat:@"links:\n%@", [links count] ? links : @"[NONE]"];
	[stringRepresentation appendFormat:@"\n\n"];
	return stringRepresentation;
}

- (void) takeDurationFromString:(NSString*)durationString { //  <duration>01:00</duration>
	// step 1: create parts of strings
	NSArray *durationComponents = [durationString componentsSeparatedByString:@":"];
	// step 2: calculate timeinterval in minutes
	int hours, minutes, seconds = 0;
	int i = 0;
	for( NSString* currentComponent in durationComponents ) {
		i++;
		switch( i ) {
			case 1:
				hours = [currentComponent intValue];
				break;
			case 2:
				minutes = [currentComponent intValue];
				break;
			case 3:
				seconds = [currentComponent intValue];
				break;
			default:
				break;
		}
	}
    double timeTntervalInSeconds = (hours*60.0*60.0)+(minutes*60.0)+seconds;
	self.duration = (NSTimeInterval)[[NSNumber numberWithInt:(hours+minutes)] doubleValue];
	self.durationSeconds = (NSTimeInterval)timeTntervalInSeconds;
}

- (void) takeStartDateTimeFromString:(NSString*)dateString {
    self.start = [dateString trimmedString];
    NSString *regex = @"[0-9]{2}:[0-9]{2}";
	NSArray *matchesArray = [dateString componentsMatchedByRegex:regex];
    NSString *timeString = nil;
    NSArray *timeComponents = nil;
    if( [matchesArray count] > 0 ) {
        timeString = [matchesArray objectAtIndex:0];
        timeComponents = [timeString componentsSeparatedByString:@":"];
    }
    self.timeHour = [[timeComponents objectAtIndex:0] integerValue];
	self.timeMinute = [[timeComponents objectAtIndex:1]  integerValue];
}

- (void) takeValuesFromDictionary:(NSDictionary*)dict {
	// NSString *className = nil;
	// className = [someObject isKindOfClass:[NSDictionary class]] ? @"NSDictionary" : @"no dict";
	// NSLog( @"allkeys = %@", [dict allKeys]  );
	if( [dict valueForKey:@"nodeName"] == nil ) return;
	NSString *attributeValue = nil;
	@try {
		attributeValue = [dict valueForKey:@"nodeAttributeArray"];
		
	}
	@catch (NSException * e) {
		// do nothing
	}
	@finally {
		// do noting
	}
}

+ (NSMutableArray*) completeEventListFromArray:(NSArray*)array withFetchLimit:(int)limitValue {
	Event *createdEvent = nil;
	NSMutableArray *listCreated = [NSMutableArray array];
	NSDictionary *currentDict = nil;
	for( int i = 0; i < [array count]; i++ ) {
		currentDict = (NSDictionary*) [array objectAtIndex:i];
		createdEvent = [[Event alloc] init];
		[createdEvent takeValuesFromDictionary:currentDict];
		[listCreated addObject:createdEvent];
	}
	return listCreated;
}

- (NSString*) stringRepresentationMail {
    return [NSString stringWithFormat:@"<b>%@</b><br>%@", [NSString placeHolder:@"(Kein Titel)" forEmptyString:title], [NSString placeHolder:@"(Kein Untertitel)" forEmptyString:subtitle]];
}

- (NSString*) stringRepresentationTwitter {
    NSString *linkHref = [self websiteHref];
    if( !linkHref ) {
        Link *firstLink = nil;
        if( links && [links count] > 0 ) {
            firstLink = [links objectAtIndex:0];
        }
        linkHref = [firstLink.href httpUrlString];
    }
    return [NSString stringWithFormat:@"\"%@\" %@", [NSString placeHolder:@"(Kein Titel)" forEmptyString:title], [NSString placeHolder:@"" forEmptyString:linkHref]];
}

- (NSDate*) calculatedDateStart {
    NSDate *dateCalculated = nil;
    // STEP 1: fetch day date
    NSDate *dateOfDay = self.day.date;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateOfDay];
    // STEP 2: fetch hour and minute
    NSDateComponents *computedComponents = [[NSDateComponents alloc] init];
    [computedComponents setDay:[comps day]];
    [computedComponents setMonth:[comps month]];
    [computedComponents setYear:[comps year]];
    [computedComponents setHour:[self timeHour]];
    [computedComponents setMinute:[self timeMinute]];
    // STEP 3: CREATE NEW DATE
    dateCalculated = [[NSCalendar currentCalendar] dateFromComponents:computedComponents];
    return dateCalculated;
}

- (NSDate*) calculatedDateEnd {
    NSDate *dateCalculated = nil;
    // STEP 1: fetch start date
    NSDate *dateStartCalculated = [self calculatedDateStart];
    // STEP 2: add duration
    NSTimeInterval durationInterval = [self durationSeconds];
    // STEP 3: CREATE NEW DATE
    dateCalculated = [dateStartCalculated dateByAddingTimeInterval:durationInterval];
    return dateCalculated;
}

// SEARCHABLE ITEM

- (NSString*) itemId {
    return [NSString stringWithFormat:@"%i", [self eventId]];
}

- (NSString*) itemTitle {
    return title;
}

- (NSString*) itemSubtitle {
    return subtitle;
}
- (NSString*) itemAbstract {
    return descriptionText;
}

- (NSString*) itemPerson {
    NSMutableString *personsString = [NSMutableString string];
    BOOL isFirst = YES;
    for( Person* currentPerson in persons ) {
        [personsString appendFormat:@"%@%@", isFirst ? @"" : @",", currentPerson.personName];
        isFirst = NO;
    }
    return personsString;
}

- (NSDate*) itemDateStart {
    NSDate *dateToReturn = nil;
    dateToReturn = [self calculatedDateStart];
    return dateToReturn;
}

- (NSDate*) itemDateEnd {
    NSDate *dateToReturn = nil;
    dateToReturn = [self calculatedDateEnd];
    return dateToReturn;
}

- (BOOL) isFavourite {
    return [[FavouriteManager sharedManager] hasStoredFavourite:self];
}

- (NSNumber*) itemSortNumberDateTime {
    NSDate *baseDateForSorting = [self itemDateStart];
    // FETCH COMPONENTS
    if( !baseDateForSorting ) return [NSNumber numberWithFloat:CGFLOAT_MAX];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit, NSMinuteCalendarUnit) fromDate:baseDateForSorting];
    NSInteger hourValue = [comps hour];
    NSInteger minuteValue = [comps minute];
    if( hourValue < 8 ) {
        hourValue = hourValue + 24;
    }
    NSInteger continuousTimeValue = (hourValue * 60) + minuteValue;
    return [NSNumber numberWithInt:continuousTimeValue];
}

@end
