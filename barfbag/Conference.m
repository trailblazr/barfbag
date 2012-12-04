//
//  Conference.m
//  AnyXML
//
//  Created by Helge Städtler on 17.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import "Conference.h"
#import "Day.h"

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

- (void) dealloc {
	[title release];
	[subtitle release];
	[venue release];
	[city release];
	[startDate release];
	[endDate release];
	[release release];
	[days release];
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


@end
