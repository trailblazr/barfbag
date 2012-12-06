//
//  BBJSONConnectOperation.h
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 02.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@protocol BBJSONConnectOperationDelegate;

@interface BBJSONConnectOperation : NSOperation <ASIHTTPRequestDelegate,ASIProgressDelegate> {
    
    id<BBJSONConnectOperationDelegate> delegate;
    NSURL *serviceUrl;
    NSString *pathComponent;
    NSURLConnection *currentConnection;
    ASIHTTPRequest *currentRequest;
    BOOL isOperationExecuting;
    BOOL isOperationFinished;
    BOOL isOperationReadyToStart;
    BOOL isOperationCancelled;
    BOOL isOperationDebugEnabled;
    SEL selectorFail;
    SEL selectorInvalid;
    SEL selectorSuccess;
    id result;
    id jsonObjectClass;
    NSDictionary *jsonMappingDictionary;
}

@property( nonatomic, assign ) id<BBJSONConnectOperationDelegate> delegate;

@property( nonatomic, assign ) SEL selectorFail;
@property( nonatomic, assign ) SEL selectorInvalid;
@property( nonatomic, assign ) SEL selectorSuccess;

@property( nonatomic, assign ) BOOL isOperationExecuting;
@property( nonatomic, assign ) BOOL isOperationFinished;
@property( nonatomic, assign ) BOOL isOperationReadyToStart;
@property( nonatomic, assign ) BOOL isOperationCancelled;
@property( nonatomic, assign ) BOOL isOperationDebugEnabled;

@property( nonatomic, retain ) NSURL *serviceUrl;
@property( nonatomic, retain ) NSString *pathComponent;
@property( nonatomic, retain ) ASIHTTPRequest *currentRequest;
@property( nonatomic, retain ) id jsonObjectClass;
@property( nonatomic, retain ) NSDictionary *jsonMappingDictionary;
@property( nonatomic, retain ) id result;

+ (BBJSONConnectOperation*) operationWithConnectUrl:(NSURL*)url andPathComponent:(NSString*)thePathComponent delegate:(id<BBJSONConnectOperationDelegate>) delegate selFail:(SEL)selectorOnFail selInvalid:(SEL)selectorOnInvalid selSuccess:(SEL)selectorOnSuccess;

- (NSURL*) connectUrl;

@end

@protocol BBJSONConnectOperationDelegate <NSObject>

@optional

- (void) operationStarted:(BBJSONConnectOperation*)operation;
- (void) operationSuccess:(BBJSONConnectOperation*)operation;
- (void) operationInvalidResponse:(BBJSONConnectOperation*)operation;
- (void) operationFailed:(BBJSONConnectOperation*)operation;

@end