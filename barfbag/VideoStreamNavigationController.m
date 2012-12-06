//
//  VideoStreamNavigationController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 04.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "VideoStreamNavigationController.h"
#import "VideoStreamsViewController.h"

@implementation VideoStreamNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.image = [UIImage imageNamed:@"video.png"];
        self.tabBarItem.title = LOC( @"Videostreams" );
        self.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationBar.tintColor = kCOLOR_BACK;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    VideoStreamsViewController *controller = [[VideoStreamsViewController alloc] initWithNibName:@"VideoStreamsViewController" bundle:nil];
    [self pushViewController:controller animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC( @"Zurück" ) style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
