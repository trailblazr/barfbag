//
//  Conference.m
//  AnyXML
//
//  Created by Helge Städtler on 17.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import "Conference.h"
#import "Day.h"
#import "Event.h"

@implementation Conference

@synthesize title;
@synthesize subtitle;
@synthesize venue;
@synthesize city;
@synthesize startDate;
@synthesize endDate;
@synthesize release;
@synthesize dayChange;
@synthesize timeslotDuration;
@synthesize days;

@synthesize cachedAvailableTracks;
@synthesize cachedAvailableTypes;
@synthesize cachedAvailableLanguages;
@synthesize cachedAvailableRooms;
@synthesize cachedAvailableSlugs;
@synthesize cachedAvailablePersons;
@synthesize cachedAvailableLinks;

- (void) dealloc {
	[title release];
	[subtitle release];
	[venue release];
	[city release];
	[startDate release];
	[endDate release];
	[release release];
	[days release];
    self.cachedAvailableTracks = nil;
    self.cachedAvailableTypes = nil;
    self.cachedAvailableLanguages = nil;
    self.cachedAvailableRooms = nil;
    self.cachedAvailableSlugs = nil;
    self.cachedAvailablePersons = nil;
    self.cachedAvailableLinks = nil;
	[super dealloc];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
		self.days = [NSMutableArray array];
    }
    return self;
}

- (NSString*) description {
	NSMutableString *stringRepresentation = [NSMutableString string];
	[stringRepresentation appendFormat:@"\nTitle = %@\n", title == nil ? @"[NIL]" : title];
	[stringRepresentation appendFormat:@"Subtitle = %@\n", subtitle == nil ? @"[NIL]" : subtitle];
	[stringRepresentation appendFormat:@"Venue = %@\n", venue == nil ? @"[NIL]" : venue];
	[stringRepresentation appendFormat:@"City = %@\n", city == nil ? @"[NIL]" : city];
	[stringRepresentation appendFormat:@"Release = %@\n", release == nil ? @"[NIL]" : release];
	[stringRepresentation appendFormat:@"Start = %@\n", startDate == nil ? @"[NIL]" : [self stringForDate:startDate]];
	[stringRepresentation appendFormat:@"End = %@\n", endDate == nil ? @"[NIL]" : [self stringForDate:endDate]];
	return stringRepresentation;
}

- (NSString*) stringForDate:(NSDate*)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.locale = [NSLocale currentLocale];
	dateFormatter.timeZone = [NSTimeZone localTimeZone];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.timeStyle = NSDateFormatterNoStyle;
	return [dateFormatter stringFromDate:date];
}

- (void) addDay:(Day*)dayToAdd {
	[days addObject:dayToAdd];
}

#pragma mark - Post Processing for convenient Access to Stuff

- (BOOL) array:(NSMutableArray*)array containsString:(NSString*)string {
    for( NSString* currentString in array ) {
        if( [currentString isEqualToString:string] ) {
            return YES;
        }
    }
    return NO;
}

- (void) addKey:(NSString*)key toArray:(NSMutableArray*)array {
    key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *keys = [key componentsSeparatedByString:@","];
    for( NSString* currentKey in keys ) {
        key = [key normalizedString];
        if( !key || [key length] == 0 ) {
            break;
        }
        else {
            if( [self array:array containsString:key] ) {
                break;
            }
            else {
                [array addObject:key];
            }
        }
    }
}

- (NSArray*) allEvents {
    NSMutableArray *allEvents = [NSMutableArray array];
    for( Day* currentDay in days ) {
        [allEvents addObjectsFromArray:currentDay.events];
    }
    return [NSArray arrayWithArray:allEvents];
}

- (void) computeCachedProperties {

    self.cachedAvailableTracks = [NSMutableArray array];
    self.cachedAvailableTypes = [NSMutableArray array];
    self.cachedAvailableLanguages = [NSMutableArray array];
    self.cachedAvailableRooms = [NSMutableArray array];
    self.cachedAvailableSlugs = [NSMutableArray array];
    self.cachedAvailablePersons = [NSMutableArray array];
    self.cachedAvailableLinks = [NSMutableArray array];
    
    NSMutableArray *allEvents = [NSMutableArray arrayWithArray:[self allEvents]];
    
    // COMPUTE LIST OF USED TRACKS
    for( Event *currentEvent in allEvents ) {
        [self addKey:currentEvent.track toArray:cachedAvailableTracks];
        [self addKey:currentEvent.type toArray:cachedAvailableTypes];
        [self addKey:currentEvent.language toArray:cachedAvailableLanguages];
        [self addKey:currentEvent.room toArray:cachedAvailableRooms];
        [self addKey:currentEvent.slug toArray:cachedAvailableSlugs];
    }
    
    NSLog( @"tracks = %@", cachedAvailableTracks );
    NSLog( @"types = %@", cachedAvailableTypes );
    NSLog( @"languages = %@", cachedAvailableLanguages );
    NSLog( @"rooms = %@", cachedAvailableRooms );
    NSLog( @"slugs = %@", cachedAvailableSlugs );
    
    NSLog( @"events in room 'saal 1': %@", [self eventsForRoom:@"saal 1"] );
    
}

- (NSArray*) eventsWithProperty:(NSString*)propertyName matchingValue:(NSString*)value {
    NSMutableArray *eventsMatching = [NSMutableArray array];
    NSArray *allEvents = [self allEvents];
    for( Event* currentEvent in allEvents ) {
        SEL selector = NSSelectorFromString(propertyName);
        id result = [currentEvent performSelector:selector];
        if( [result isKindOfClass:[NSString class]] ) {
            NSString *resultNormalized = [(NSString*)result normalizedString];
            if( [resultNormalized isEqualToString:value] ) {
                [eventsMatching addObject:currentEvent];
            }
        }
        else {
            NSLog( @"No NSString Property: %@", propertyName );
        }
    }
    return [NSArray arrayWithArray:eventsMatching];
}

- (NSArray*) eventsForTrack:(NSString*)track {
    return [self eventsWithProperty:@"track" matchingValue:track];
}

- (NSArray*) eventsForType:(NSString*)type {
    return [self eventsWithProperty:@"type" matchingValue:type];
}

- (NSArray*) eventsForLanguage:(NSString*)language {
    return [self eventsWithProperty:@"language" matchingValue:language];
}

- (NSArray*) eventsForRoom:(NSString*)room {
    return [self eventsWithProperty:@"room" matchingValue:room];
}

- (NSArray*) eventsForSlug:(NSString*)slug {
    return [self eventsWithProperty:@"slug" matchingValue:slug];
}

- (NSArray*) eventsForPerson:(Person*)person {
    // TODO: implement
    return nil;
}

- (NSArray*) eventsForLink:(Link*)link {
    // TODO: implement
    return nil;
}


@end
