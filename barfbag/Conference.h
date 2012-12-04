//
//  Conference.h
//  AnyXML
//
//  Created by Helge Städtler on 17.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Day;

@interface Conference : NSObject {

	NSString *title;
	NSString *subtitle;
	NSString *venue;
	NSString *city;
	NSDate *startDate;
	NSDate *endDate;
	NSString *release;
	int dayChange;
	int timeslotDuration;
	
	NSMutableArray* days;
}

@property(nonatomic, assign) int dayChange;
@property(nonatomic, assign) int timeslotDuration;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *subtitle;
@property(nonatomic, retain) NSString *venue;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSDate *endDate;
@property(nonatomic, retain) NSString *release;
@property(nonatomic, retain) NSMutableArray* days;

- (void) addDay:(Day*)dayToAdd;
- (NSString*) stringForDate:(NSDate*)date;

@end



/*
 
 <conference>
 <title>27th Chaos Communication Congress</title>
 <subtitle>We come in peace</subtitle>
 <venue>bcc</venue>
 <city>Berlin</city>
 <start>2010-12-27</start>
 <end>2010-12-30</end>
 <days>4</days>
 <release>Version 0.35b</release>
 <day_change>04:00</day_change>
 <timeslot_duration>00:15</timeslot_duration>
 </conference>
 
 */