//
//  Day.h
//  AnyXML
//
//  Created by Helge Städtler on 16.01.11.
//  Copyright 2011 staedtler development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@interface Day : NSObject {
	int dayIndex;
	NSDate *date;
	NSMutableArray *events;
}

@property(nonatomic, assign) int dayIndex; //       <day date="2010-12-27" index="1">
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSMutableArray *events;

- (void) addEvent:(Event*)eventToAdd;

@end
