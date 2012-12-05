//
//  WelcomeViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericViewController.h"

@interface WelcomeViewController : GenericViewController {

    IBOutlet UILabel *congressMessagePlainLabel;
    IBOutlet UILabel *congressMessageSemiboldLabel;
    IBOutlet UILabel *barfBagBrandLabel;
}

@property( nonatomic, retain ) UILabel *congressMessagePlainLabel;
@property( nonatomic, retain ) UILabel *congressMessageSemiboldLabel;
@property( nonatomic, retain ) UILabel *barfBagBrandLabel;

@end
