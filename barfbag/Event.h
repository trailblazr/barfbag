//
//  Event.h
//  AnyXML
//
//  Created by Helge Städtler on 26.12.10.
//  Copyright 2010 staedtler development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import "Person.h"
#import "Link.h"
#import "SearchableItem.h"

@class Day;

@interface Event : SearchableItem {

	NSInteger eventId;
	NSTimeInterval duration;
	NSTimeInterval durationSeconds;
	NSString *start;
	NSString *title;	
	NSString *subtitle;
	NSString *room;
	NSString *slug;
	NSString *track;
	NSString *type;
	NSString *language;
	NSString *abstract;
	NSString *descriptionText;
	NSMutableArray *persons;
	NSMutableArray *links;	
    NSInteger timeHour;
    NSInteger timeMinute;
    NSDate *dateStart;
    NSDate *dateEnd;
    Day *day;
}

@property(nonatomic, assign) NSInteger eventId; //       <event id="4302">
@property(nonatomic, assign) NSTimeInterval duration; //         <duration>01:00</duration>
@property(nonatomic, assign) NSTimeInterval durationSeconds; //         <duration>01:00</duration>
@property(nonatomic, retain) NSString *start; //         <start>11:30</start>
@property(nonatomic, retain) NSString *room; //         <room>Saal 1</room>
@property(nonatomic, retain) NSString *slug; //      <slug>27c3_keynote_we_come_in_peace</slug>
@property(nonatomic, retain) NSString *type; //      <type>contest</type>
@property(nonatomic, retain) NSString *title; //         <title>27C3 Keynote</title>
@property(nonatomic, retain) NSString *subtitle;//         <subtitle>We come in Peace</subtitle>
@property(nonatomic, retain) NSString *track; //         <track>Society</track>
@property(nonatomic, retain) NSString *language; //         <language>en</language>
@property(nonatomic, retain) NSString *abstract; //         <abstract></abstract>
@property(nonatomic, retain) NSString *descriptionText; //         <description></description>
@property(nonatomic, retain) NSMutableArray *persons;
@property(nonatomic, retain) NSMutableArray *links;
@property(nonatomic, assign) NSInteger timeHour;
@property(nonatomic, assign) NSInteger timeMinute;
@property(nonatomic, retain) NSDate *dateStart;
@property(nonatomic, retain) NSDate *dateEnd;
@property(nonatomic, retain) Day *day;


+ (NSMutableArray*) completeEventListFromArray:(NSArray*)array withFetchLimit:(int)limitValue;
- (void) addPerson:(Person*)personToAdd;
- (void) addLink:(Link*)linkToAdd;
- (NSString*) pngIconHref;
- (NSString*) websiteHref;
- (NSString*) speakerList;
- (NSString*) localizedLanguageName;

- (void) takeValuesFromDictionary:(NSDictionary*)dict;
- (void) takeDurationFromString:(NSString*)durationString;
- (void) takeStartDateTimeFromString:(NSString*)dateString;
- (BOOL) isTrack:(NSString*)trackName;

- (NSString*) stringRepresentationMail;
- (NSString*) stringRepresentationTwitter;

@end
