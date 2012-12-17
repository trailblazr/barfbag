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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemSortNumberDateTime" ascending:TRUE];
     [eventsUnsorted sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray *eventsSorted = [NSArray arrayWithArray:eventsUnsorted];
    /*
    NSArray *eventsSorted =  [eventsUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SearchableItem *item1 = (SearchableItem*)obj1;
        SearchableItem *item2 = (SearchableItem*)obj2;
        if( item1.itemSortNumberDateTime > item2.itemSortNumberDateTime ) {
            return NSOrderedDescending;
        } else if( item1.itemSortNumberDateTime < item2.itemSortNumberDateTime ) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
     */
    /*
    for( Event *currentEvent in eventsSorted ) {
        NSLog( @"DAY: %@ TIME: %i:%i", currentEvent.day.date, currentEvent.timeHour, currentEvent.timeMinute );
    }
     */
    return eventsSorted;
}

@end
