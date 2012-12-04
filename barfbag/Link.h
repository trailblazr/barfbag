//
//  Link.h
//  AnyXML
//
//  Created by Helge Städtler on 20.12.11.
//  Copyright (c) 2011 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

@interface Link : NSObject {
    
	NSInteger linkId;
    NSString *href;
    NSString *title;
}

@property(nonatomic, assign) NSInteger linkId;
@property(nonatomic, retain) NSString *href;
@property(nonatomic, retain) NSString *title;

@end
