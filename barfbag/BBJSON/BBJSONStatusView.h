//
//  BBJSONStatusView.h
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 03.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ResultStatusOK = 0,
    ResultStatusWARN = 1,
    ResultStatusFAIL = 2,
    ResultStatusHIDDEN = 3,
} ResultStatus;

@interface BBJSONStatusView : UIImageView {
    
    ResultStatus currentStatus;
    
}

@property( nonatomic, assign ) ResultStatus currentStatus;

- (void) updateStatus:(ResultStatus)statusValue;

@end
