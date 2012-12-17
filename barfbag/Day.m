//
//  Day.m
//  AnyXML
//
//  Created by Helge Städtler on 16.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import "Day.h"
#import "Event.h"

@implementation Day

@synthesize dayIndex;
@synthesize date;
@synthesize events;

- (void) dealloc {
	[date release];
	[events release];
	[super dealloc];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
		self.events = [NSMutableArray array];
		self.date = [NSDate date];
		self.dayIndex = -1;
    }
    return self;
}

- (void) addEvent:(Event*)eventToAdd {
    eventToAdd.day = self;
	[events addObject:eventToAdd];
}

- (NSArray*) eventsSorted {
    NSMutableArray *eventsUnsorted = [NSMutableArray arrayWithArray:events];
    return [eventsUnsorted sortedArrayUsingSelector:@selector(itemSortNumberDateTime)];
}

@end
