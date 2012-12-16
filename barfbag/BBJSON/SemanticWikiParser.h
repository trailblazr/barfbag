//
//  SemanticWikiParser.h
//  barfbag
//
//  Created by Lincoln Six Echo on 16.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SemanticWikiParserDelegate;

@interface SemanticWikiParser : NSObject {

    id <SemanticWikiParserDelegate> delegate;
	NSMutableArray *assembliesArray;
	NSMutableArray *workshopsArray;

}

@property(nonatomic, assign) id <SemanticWikiParserDelegate> delegate;
@property(nonatomic, retain) NSMutableArray *assembliesArray;
@property(nonatomic, retain) NSMutableArray *workshopsArray;

- (void) startParsingResponseData:(NSData*)data;
- (void) startParsingResponseString:(NSString*)string;

@end

@protocol SemanticWikiParserDelegate <NSObject>

- (void) barfBagParser:(SemanticWikiParser*)parser parsedAssemblies:(NSArray *)assembliesArray;
- (void) barfBagParser:(SemanticWikiParser*)parser parsedWorkshops:(NSArray *)workshopsArray;

@end
