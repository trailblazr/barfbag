//
//  Person.m
//  AnyXML
//
//  Created by Helge Städtler on 20.12.11.
//  Copyright (c) 2011 appdoctors. All rights reserved.
//

#import "Person.h"
#import "MasterConfig.h"
#import "SinaURLConnection.h"

@implementation Person

@synthesize personId;
@synthesize personName;
@synthesize imageInMemory;

- (void) dealloc {
    self.personName = nil;
    self.imageInMemory = nil;
    [super dealloc];
}

- (NSString*) description {
	NSMutableString *stringRepresentation = [NSMutableString string];
	[stringRepresentation appendFormat:@"PERSON (%i)\n", personId];
	[stringRepresentation appendFormat:@"personName = %@\n", personName == nil ? @"[NIL]" : personName];
	[stringRepresentation appendFormat:@"icon = %@\n", [self pngIconHref]];
	[stringRepresentation appendFormat:@"\n\n"];
	return stringRepresentation;
}

- (NSString*) imageName {
    return [NSString stringWithFormat:@"person-%i-128x128.png", personId];
}

- (NSString*) pngIconHref {
    NSString *imageTemplateUrl = [[MasterConfig sharedConfiguration] urlStringForKey:kURL_KEY_29C3_PERSON_IMG];
    imageTemplateUrl = [imageTemplateUrl stringByReplacingOccurrencesOfString:@"$id$" withString:[self personIdKey]];
    return imageTemplateUrl;
}

- (NSString*) websiteHref {
    NSString *imageTemplateUrl = [[MasterConfig sharedConfiguration] urlStringForKey:kURL_KEY_29C3_PERSON_SITE];
    imageTemplateUrl = [imageTemplateUrl stringByReplacingOccurrencesOfString:@"$id$" withString:[self personIdKey]];
    return imageTemplateUrl;
}

- (NSString*) personIdKey {
    return [NSString stringWithFormat:@"%i", personId];
}

- (void) fetchCachedImage {
    NSString *urlString = [self pngIconHref];
    if( DEBUG ) NSLog( @"PERSON IMAGE: URL = %@", urlString );
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:kCONNECTION_TIMEOUT];
    [SinaURLConnection asyncConnectionWithRequest:theRequest completionBlock:^(NSData *data, NSURLResponse *response) {
        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
        if( DEBUG ) NSLog( @"PERSON IMAGE: HTML CONNECTION RESPONSECODE: %i", statusCode );
        // REPLACE STORED OFFLINE DATA
        if( statusCode != 200 ) {
            // do nothing
        }
        else {
            BOOL isCached = NO;
            if( data && [data length] > 500 ) {
                isCached = NO;
                // SAVE INFOS
                NSString *pathToStoreFile = [NSString stringWithFormat:@"%@/%@", kFOLDER_DOCUMENTS ,[self imageName]];
                BOOL hasStoredFile = [data writeToFile:pathToStoreFile atomically:YES];
                if( !hasStoredFile ) {
                    if( DEBUG ) NSLog( @"PERSON IMAGE: BINARY SAVING FAILED!!!" );
                }
                else {
                    if( DEBUG ) NSLog( @"PERSON IMAGE: BINARY SAVING SUCCEEDED." );
                    @try {
                        NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@", kFOLDER_DOCUMENTS ,[self imageName]];
                        self.imageInMemory = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
                    }
                    @catch (NSException *exception) {
                        // do nothing
                    }
                }
            }
        }
    } errorBlock:^(NSError *error) {
        if( DEBUG ) NSLog( @"PERSON IMAGE: NO INTERNET CONNECTION." );
    } uploadProgressBlock:^(float progress) {
        // do nothing
    } downloadProgressBlock:^(float progress) {
        // TODO: UPDATE PROGRESS DISPLAY ...
    } cancelBlock:^(float progress) {
        // nothing
    }];
}

- (UIImage*) cachedImage {
    if( imageInMemory ) return imageInMemory;
    @try {
        NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@", kFOLDER_DOCUMENTS ,[self imageName]];
        self.imageInMemory = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
    }
    @catch (NSException *exception) {
        // do nothing
    }
    if( !imageInMemory ) {
        self.imageInMemory = [UIImage imageNamed:@"person-0-128x128.png"];
    }
    return imageInMemory;
}

@end
