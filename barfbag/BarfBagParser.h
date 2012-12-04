//
//  BarfBagParser.h
//  AnyXML
//
//  Created by Helge Städtler on 16.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conference;
@class Day;
@class Event;
@class Person;
@class Link;

@protocol BarfBagParserDelegate;

@interface BarfBagParser : NSObject <NSXMLParserDelegate> {

	id <BarfBagParserDelegate> delegate;
	NSMutableArray *conferencesParsed;
	NSMutableArray *daysParsed;
	NSMutableArray *eventsParsed;
	NSMutableArray *personsParsed;
	NSMutableArray *linksParsed;
	NSMutableData *responseData;
	NSString *currentXmlElement;
	Conference *currentConference;
	Day *currentDay;
	Event *currentEvent;
	Person *currentPerson;
	Link *currentLink;
	
	NSMutableDictionary *currentElementKeyValues;
}

@property(nonatomic, assign) id <BarfBagParserDelegate> delegate;
@property(nonatomic, retain) NSMutableArray *conferencesParsed;
@property(nonatomic, retain) NSMutableArray *daysParsed;
@property(nonatomic, retain) NSMutableArray *eventsParsed;
@property(nonatomic, retain) NSMutableArray *personsParsed;
@property(nonatomic, retain) NSMutableArray *linksParsed;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSString *currentXmlElement;
@property(nonatomic, retain) Conference *currentConference;
@property(nonatomic, retain) Day *currentDay;
@property(nonatomic, retain) Event *currentEvent;
@property(nonatomic, retain) Person *currentPerson;
@property(nonatomic, retain) Link *currentLink;

@property(nonatomic, retain) NSMutableDictionary *currentElementKeyValues;

- (void) startParsingResponseData;
- (void) appendString:(NSString*)stringToAppend forKey:(NSString*)key withPrefix:(NSString*)prefix;
- (NSString*) stringValueForKey:(NSString*)key withPrefix:(NSString*)prefix;
- (NSDate*) dateFromString:(NSString*)string forFormat:(NSString*)format;

@end

@protocol BarfBagParserDelegate <NSObject>

- (void) barfBagParser:(BarfBagParser*)parser parsedConferences:(NSArray *)conferencesArray;

@end
