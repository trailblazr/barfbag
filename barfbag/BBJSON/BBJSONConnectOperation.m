//
//  BBJSONConnectOperation.m
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 02.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import "BBJSONConnectOperation.h"
#import "NSObject+SBJson.h"
#import "NSObject+JTObjectMapping.h"

@implementation BBJSONConnectOperation

@synthesize serviceUrl;
@synthesize pathComponent;
@synthesize isOperationExecuting;
@synthesize isOperationFinished;
@synthesize isOperationReadyToStart;
@synthesize isOperationCancelled;
@synthesize isOperationDebugEnabled;
@synthesize selectorFail;
@synthesize selectorInvalid;
@synthesize selectorSuccess;
@synthesize delegate;
@synthesize jsonObjectClass;
@synthesize jsonMappingDictionary;
@synthesize result;
@synthesize currentRequest;

+ (BBJSONConnectOperation*) operationWithConnectUrl:(NSURL*)url andPathComponent:(NSString*)thePathComponent delegate:(id<BBJSONConnectOperationDelegate>) delegate selFail:(SEL)selectorOnFail selInvalid:(SEL)selectorOnInvalid selSuccess:(SEL)selectorOnSuccess {
    BBJSONConnectOperation *operation = [[[BBJSONConnectOperation alloc] init] autorelease];
    // SETUP
    operation.serviceUrl = url;
    operation.pathComponent = thePathComponent;
    operation.isOperationExecuting = NO;
    operation.isOperationFinished = NO;
    operation.isOperationReadyToStart = NO;
    operation.isOperationCancelled = NO;
    operation.isOperationDebugEnabled = NO;
    operation.selectorFail = selectorOnFail;
    operation.selectorSuccess = selectorOnSuccess;
    operation.selectorInvalid = selectorOnInvalid;
    operation.delegate = delegate;
    return operation;
}

- (void) dealloc {
    self.delegate = nil;
    self.serviceUrl = nil;
    self.pathComponent = nil;
    self.jsonObjectClass = nil;
    self.jsonMappingDictionary = nil;
    self.result = nil;
    self.currentRequest.delegate = nil;
    self.currentRequest = nil;
    [super dealloc];
}

- (NSURL*) connectUrl {
    NSString *urlString = nil;
    if( pathComponent ) {
        urlString = [NSString stringWithFormat:@"%@/%@", [serviceUrl absoluteString], pathComponent];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@", [serviceUrl absoluteString]];
    }
    return [NSURL URLWithString:urlString];
}

#pragma mark - different ASI HTTP request methods

- (void) addUserAgentInfoToRequest:(ASIHTTPRequest*)request {
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *appPlatform = [[UIDevice currentDevice] platformString];
	NSString *appSystemVersion = [[UIDevice currentDevice] systemVersion];
	NSString *appLanguageContext = [[NSLocale currentLocale] localeIdentifier];
	NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	
	NSString *uaString = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; %@)", appDisplayName, appVersion, appPlatform, appSystemVersion, appLanguageContext];	
	
	if( DEBUG ) NSLog( @"CONNECTION: USER AGENT: %@", uaString );
    [request addRequestHeader:@"User-Agent" value:uaString];
    request.useCookiePersistence = NO;
}

- (ASIFormDataRequest*) requestPostFormDataWithTimeoutInterval:(NSTimeInterval)timeoutInterval {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self connectUrl]];
    self.currentRequest = request;
    request.timeOutSeconds = timeoutInterval;
    request.postFormat = ASIMultipartFormDataPostFormat;
    [self addUserAgentInfoToRequest:request];
	return request;
}

- (ASIFormDataRequest*) requestPostUrlEncodedWithTimeoutInterval:(NSTimeInterval)timeoutInterval {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self connectUrl]];
    self.currentRequest = request;
    request.timeOutSeconds = timeoutInterval;
    request.postFormat = ASIURLEncodedPostFormat;
    [self addUserAgentInfoToRequest:request];
	return request;
}

- (ASIHTTPRequest*) requestWithTimeoutInterval:(NSTimeInterval)timeoutInterval {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self connectUrl]];
    self.currentRequest = request;
    request.timeOutSeconds = timeoutInterval;
    [self addUserAgentInfoToRequest:request];
	return request;
}

- (ASIHTTPRequest*)requestForAbsoluteUrl:(NSString *)absoluteUrl withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	NSURL *url = [NSURL URLWithString:absoluteUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    self.currentRequest = request;
    request.timeOutSeconds = timeoutInterval;
    [self addUserAgentInfoToRequest:request];
	return request;
}


#pragma mark - ASIProgressDelegate

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
    if( isOperationDebugEnabled ) NSLog( @"ASI: didReceiveBytes %@", [NSNumber numberWithLongLong:bytes] );
	NSUInteger length = [request.responseData length];
	NSNumber *receivedLength = [NSNumber numberWithUnsignedInt:length];
    if( isOperationDebugEnabled ) NSLog( @"%s: RECEIVED BYTES = %@", __PRETTY_FUNCTION__, receivedLength );
	// remoteConnection.receivedLength = receivedLength;
    // [remoteConnection.target updateWithProgress:[NSNumber numberWithDouble:[self receivedPercentage]]];
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
    if( isOperationDebugEnabled ) NSLog( @"ASI: didSendBytes %@", [NSNumber numberWithLongLong:bytes] );
    
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    if( isOperationDebugEnabled ) NSLog( @"ASI: requestStarted: %@", [request.url absoluteString] );
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    if( isOperationDebugEnabled ) NSLog( @"ASI: didReceiveResponseHeaders %@", responseHeaders );
    long long expectedContentLength = [[request.responseHeaders valueForKey:@"Content-Length"] longLongValue];
    NSNumber *totalLength = [NSNumber numberWithLongLong:expectedContentLength];
    if( isOperationDebugEnabled ) NSLog( @"%s: totalLength = %@", __PRETTY_FUNCTION__, totalLength );
    // remoteConnection.totalLength = totalLength;
}

/*
 - (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
 NSLog( @"ASI: willRedirectToURL: %@",newURL );
 }
 */

- (void)requestRedirected:(ASIHTTPRequest *)request {
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
        self.currentRequest.delegate = nil;
        if( isOperationDebugEnabled ) NSLog( @"ASI: requestFinished" );
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if( isOperationDebugEnabled ) NSLog( @"RESPONSE CODE: %i", request.responseStatusCode );
        
        if( request.responseData == nil && request.responseString == nil ) {
            if( isOperationDebugEnabled ) NSLog( @"ATTENTION: NO RESPONSE DATA. RESPONSE WAS PROBABLY NOT OF PROTOCOL 'HTTP'" );
        }
        if( request.responseStatusCode < 500 ) { // SUCCESS: SOME RESULT
            self.result = nil;
            @try {
                NSString *type = [request.responseHeaders valueForKey:@"Content-Type"];
                type = [type lowercaseString];
                if( isOperationDebugEnabled ) NSLog( @"Content-Type of response = %@", type );
                
                // NSLog( @"connection.request.responseData = %@", request.responseData ? request.responseData : @"[NIL]" );
                if( isOperationDebugEnabled ) NSLog( @"\nrequest.responseString = \n\n%@\n\n", request.responseString ? request.responseString : @"[NIL]" );
                
                if( [type containsString:@"json"] || [type containsString:@"text"] ) {
                    self.result = [jsonObjectClass objectFromJSONObject:[request.responseString JSONValue] mapping:jsonMappingDictionary];
                    if( !result ) {
                        @try {
                            self.result = [request.responseString JSONValue];
                        }
                        @catch (NSException *exception) {
                            NSLog( @"JSON CONNECTOR: EXCEPTION = %@", exception );
                            self.result = nil;
                        }
                        @finally {
                            // do something
                        }
                    }
                    if( !result ) {
                        // self.result = request.responseString;
                    }
                }
                else if( [type containsString:@"text"] ) {
                    self.result = [[[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding] autorelease];
                }
                else if( strnstr([type cStringUsingEncoding:NSUTF8StringEncoding], "plist", [type length]) ) {
                    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temporary.plist"];
                    [request.responseData writeToFile:path atomically:NO];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
                    self.result = dict;
                }    
                else {
                    self.result = request.responseData;
                }
            }
            @catch (NSException *exception) {
                if( isOperationDebugEnabled ) NSLog( @"FATAL ERROR: %s ---> %@", __PRETTY_FUNCTION__, exception );
            }
            @finally {
                // something
            }
        }
        else { // INVALID: NO RESULT
            if( delegate && [delegate respondsToSelector:@selector(operationInvalidResponse:)] ) {
                [(id)delegate performSelector:@selector(operationInvalidResponse:) onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [delegate operationInvalidResponse:self];
            }
            if( selectorInvalid != NULL ) {
                [(id)delegate performSelector:selectorInvalid onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [(id)delegate performSelector:selectorInvalid withObject:self];
            }
        }
        if( !result ) {
            if( delegate && [delegate respondsToSelector:@selector(operationInvalidResponse:)] ) {
                [(id)delegate performSelector:@selector(operationInvalidResponse:) onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [delegate operationInvalidResponse:self];
            }
            if( selectorInvalid != NULL ) {
                [(id)delegate performSelector:selectorInvalid onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [(id)delegate performSelector:selectorInvalid withObject:self];
            }
        }
        else {
            if( delegate && [delegate respondsToSelector:@selector(operationSuccess:)] ) {
                [(id)delegate performSelector:@selector(operationSuccess:) onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [delegate operationSuccess:self];
            }
            if( delegate && selectorSuccess != NULL ) {
                [(id)delegate performSelector:selectorSuccess onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
                // [(id)delegate performSelector:selectorSuccess withObject:self];
            }    
        }
        self.isOperationExecuting = NO;
        self.isOperationFinished = YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    self.currentRequest.delegate = nil;
        if( isOperationDebugEnabled ) NSLog( @"ASI: requestFailed" );
        if( isOperationDebugEnabled ) NSLog( @"RESPONSE CODE: %i", request.responseStatusCode );
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if( delegate && [delegate respondsToSelector:@selector(operationFailed:)] ) {
            [(id)delegate performSelector:@selector(operationFailed:) onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
            //[delegate operationFailed:self];
        }
        if( selectorFail != NULL ) {
            [(id)delegate performSelector:selectorFail onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
            //[(id)delegate performSelector:selectorFail withObject:self];
        }
    // DISABLED BECAUSE AT THIS POINT OF TIME THE OPERATION iS ALREADY RELEASED --> CRASH!!!
    /*
    self.isOperationExecuting = NO;
    self.isOperationFinished = YES;
     */
}



#pragma mark - NSOperation methods

- (void) main { // EXECUTE STUFF HERE
    if( delegate && [delegate respondsToSelector:@selector(operationStarted:)] ) {
        [(id)delegate performSelector:@selector(operationStarted:) onThread:[NSThread mainThread] withObject:self waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
        // [delegate operationStarted:self];
    }
    ASIHTTPRequest *request = [self requestWithTimeoutInterval:60.0f];
    request.shouldRedirect = YES; // FOLLOW REDIRECTS (e.g. for secure connections)
    request.validatesSecureCertificate = kASIHTTP_SHOULD_VALIDATE_SECURE_CERTIFICATE;
    request.delegate = self;
    // request.uploadProgressDelegate = nil;
    // request.downloadProgressDelegate = nil;
    // request.showAccurateProgress = YES;
    [request addRequestHeader:@"Accept" value:@"application/json"]; // CONFIG FOR JSON
    [request startAsynchronous]; // FROM NOW ON ASI is in Control via its delegates
}

- (void) start {
    if( !isOperationExecuting ) {
        self.isOperationExecuting = YES;
        if( !isOperationCancelled ) {
            [self main];
        }
    }
}

- (void) cancel {
    self.currentRequest.delegate = nil;
    [self.currentRequest cancel];
    self.isOperationCancelled = YES;
    self.isOperationExecuting = NO;
    self.isOperationFinished = YES;
}

- (BOOL) isReady {
    return isOperationReadyToStart;
}

- (BOOL) isConcurrent {
    return YES;
}

- (BOOL) isExecuting {
    return isOperationExecuting;
}

- (BOOL) isFinished {
    return isOperationFinished;
}

@end
