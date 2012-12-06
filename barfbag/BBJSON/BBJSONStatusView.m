//
//  BBJSONStatusView.m
//  SimpleConnectorJSON
//
//  Created by Helge Städtler on 03.07.12.
//  Copyright (c) 2012 trailblazr. All rights reserved.
//

#import "BBJSONStatusView.h"

@implementation BBJSONStatusView

@synthesize currentStatus;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateStatus:(ResultStatus)statusValue {
    self.hidden = NO;
    switch( statusValue ) {

        case ResultStatusOK:
            self.image = [UIImage imageNamed:@"icon_accepted_48.png"];
            break;

        case ResultStatusWARN:
            self.image = [UIImage imageNamed:@"icon_warning_48.png"];
            break;

        case ResultStatusFAIL:
            self.image = [UIImage imageNamed:@"icon_cancel_48.png"];
            break;

        case ResultStatusHIDDEN:
            self.hidden = YES;
            break;

        default:
            break;
    }
}

@end
