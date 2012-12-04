//
//  Person.h
//  AnyXML
//
//  Created by Helge Städtler on 20.12.11.
//  Copyright (c) 2011 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

@interface Person : NSObject {
    
	NSInteger personId;
    NSString *personName;
}

@property(nonatomic, assign) NSInteger personId; //       <person id="4302">
@property(nonatomic, retain) NSString *personName; //       <person id="5">Alien8</person>

- (NSString*) pngIconHref;

@end
