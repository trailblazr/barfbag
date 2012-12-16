//
//  SemanticWikiParser.m
//  barfbag
//
//  Created by Lincoln Six Echo on 16.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "SemanticWikiParser.h"


@implementation SemanticWikiParser

@synthesize delegate;
@synthesize assembliesArray;
@synthesize workshopsArray;

- (void) dealloc {
    self.delegate = nil;
    self.assembliesArray = nil;
    self.workshopsArray = nil;
    [super dealloc];
}

- (void) startParsingResponseData:(NSData*)data {

}

- (void) startParsingResponseString:(NSString*)string {

    
}

@end

