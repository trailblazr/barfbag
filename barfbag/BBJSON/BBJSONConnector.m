//
//  BBJSONConnector.m
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 02.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import "BBJSONConnector.h"

@implementation BBJSONConnector

static BBJSONConnector *sharedInstance = nil;

@synthesize connectorQueue;

NSInteger connections = 0;

+ (BBJSONConnector*) instance {
	@synchronized(self) {
		if( nil == sharedInstance ) {
			sharedInstance = [[super allocWithZone:NULL] init];
            // SETUP STUFF
            // sharedInstance.connectorQueue = [NSOperationQueue mainQueue];
            sharedInstance.connectorQueue = [[NSOperationQueue alloc] init];
		}
	}
	return sharedInstance;
}

- (void) dealloc {
    
    [self operationCancelAll];
    self.connectorQueue = nil;
    
    [super dealloc];
}

- (void) operationCancelAll {
    [connectorQueue cancelAllOperations];
}

- (void) operationAdd:(NSOperation *)operation {
    [connectorQueue addOperation:operation];
    connections++;
}

- (void) operationInitiate:(BBJSONConnectOperation*)connectOperation {
    connectOperation.isOperationReadyToStart = YES;
    [self operationAdd:connectOperation];
    if( DEBUG ) NSLog( @"JSON OPERATION ADDED #%i: %@", connections, [[connectOperation connectUrl] absoluteString] );
    [connectOperation start];
}

- (void) operationCancelAllWithDelegate:(id<BBJSONConnectOperationDelegate>)myDelegate {
    NSMutableArray *operationsToCancel = [NSMutableArray array];
    @synchronized( self.connectorQueue ) {
        for( BBJSONConnectOperation *currentOperation in connectorQueue.operations ) {
            if( currentOperation.delegate == myDelegate ) {
                [operationsToCancel addObject:currentOperation];
            }
        }
        if( [operationsToCancel count] > 0 ) {
            if( DEBUG ) NSLog( @"ABORTING RUNNING OPERATIONS..." );
            for( NSOperation *currentOpToCancel in operationsToCancel ) {
                [currentOpToCancel cancel];
            }
            if( DEBUG ) NSLog( @"ABORTED %i OPERATIONS.", [operationsToCancel count] );
        }
    }
    operationsToCancel = nil;    
}

@end
