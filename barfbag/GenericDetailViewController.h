//
//  GenericDetailViewController.h
//  barfbag
//
//  Created by Lincoln Six Echo on 10.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericViewController.h"

@interface GenericDetailViewController : GenericViewController {

    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* subtitleLabel;
    IBOutlet UILabel* timeStart;
    IBOutlet UILabel* timeDuration;
    IBOutlet UILabel* roomLabel;
    IBOutlet UILabel* dateLabel;
    IBOutlet UILabel* languageLabel;
    IBOutlet UILabel* trackLabel;
    IBOutlet UILabel* speakerLabel;

}

@property( nonatomic, retain ) UILabel* titleLabel;
@property( nonatomic, retain ) UILabel* subtitleLabel;
@property( nonatomic, retain ) UILabel* timeStart;
@property( nonatomic, retain ) UILabel* timeDuration;
@property( nonatomic, retain ) UILabel* roomLabel;
@property( nonatomic, retain ) UILabel* dateLabel;
@property( nonatomic, retain ) UILabel* languageLabel;
@property( nonatomic, retain ) UILabel* trackLabel;
@property( nonatomic, retain ) UILabel* speakerLabel;

@end
