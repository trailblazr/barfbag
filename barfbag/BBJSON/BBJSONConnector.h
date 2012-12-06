//
//  BBJSONConnector.h
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 02.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBJSONConnectOperation.h"

@interface BBJSONConnector : NSObject {

    NSOperationQueue *connectorQueue;
}

@property( nonatomic, strong ) NSOperationQueue *connectorQueue;

+ (BBJSONConnector*) instance;

- (void) operationCancelAll;
- (void) operationAdd:(NSOperation *)operation;
- (void) operationInitiate:(BBJSONConnectOperation*)connectOperation;

- (void) operationCancelAllWithDelegate:(id<BBJSONConnectOperationDelegate>)myDelegate;

@end
