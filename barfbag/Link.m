//
//  Link.m
//  AnyXML
//
//  Created by Helge Städtler on 20.12.11.
//  Copyright (c) 2011 appdoctors. All rights reserved.
//

#import "Link.h"

@implementation Link

@synthesize linkId;
@synthesize href;
@synthesize title;

- (NSString*) description {
	NSMutableString *stringRepresentation = [NSMutableString string];
	[stringRepresentation appendFormat:@"LINK\n"];
	[stringRepresentation appendFormat:@"href = %@\n", href == nil ? @"[NIL]" : href];
	[stringRepresentation appendFormat:@"title = %@\n", title == nil ? @"[NIL]" : title];
	[stringRepresentation appendFormat:@"\n\n"];
	return stringRepresentation;
}

@end
