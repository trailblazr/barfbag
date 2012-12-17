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
    UIImage *imageInMemory;
}

@property( nonatomic, assign ) NSInteger personId; //       <person id="4302">
@property( nonatomic, retain ) NSString *personName; //       <person id="5">Alien8</person>
@property( nonatomic, retain ) UIImage *imageInMemory; //       <person id="5">Alien8</person>

- (NSString*) pngIconHref;
- (NSString*) websiteHref;
- (NSString*) personIdKey;
- (UIImage*) cachedImage;
- (void) fetchCachedImage;

@end
