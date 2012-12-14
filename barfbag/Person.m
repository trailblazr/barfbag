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
    NSString *imageName = [self imageName];
    return [NSString stringWithFormat:@"%@/%@", [[MasterConfig sharedConfiguration] urlStringForKey:kURL_KEY_29C3_IMAGES], imageName];
}

- (NSString*) personIdKey {
    return [NSString stringWithFormat:@"%i", personId];
}

- (void) fetchCachedImage {
    NSString *urlString = [self pngIconHref];
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
    UIImage *imageFetched = nil;
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@", kFOLDER_DOCUMENTS ,[self imageName]];
    @try {
        imageFetched = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
    }
    @catch (NSException *exception) {
        // do nothing
    }
    return imageFetched;
}

@end
