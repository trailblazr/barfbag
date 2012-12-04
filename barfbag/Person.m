//
//  Person.m
//  AnyXML
//
//  Created by Helge Städtler on 20.12.11.
//  Copyright (c) 2011 appdoctors. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize personId;
@synthesize personName;

- (NSString*) description {
	NSMutableString *stringRepresentation = [NSMutableString string];
	[stringRepresentation appendFormat:@"PERSON (%i)\n", personId];
	[stringRepresentation appendFormat:@"personName = %@\n", personName == nil ? @"[NIL]" : personName];
	[stringRepresentation appendFormat:@"icon = %@\n", [self pngIconHref]];
	[stringRepresentation appendFormat:@"\n\n"];
	return stringRepresentation;
}

- (NSString*) pngIconHref {
    NSString *imageName = [NSString stringWithFormat:@"person-%i-128x128.png", personId];
    return [NSString stringWithFormat:@"%@/%@", kURL_IMAGE_PATH, imageName];
}

@end
