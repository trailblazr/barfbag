//
//  ScheduleSemanticNavigationController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 06.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "ScheduleSemanticNavigationController.h"
#import "SemanticItemsViewController.h"

@implementation ScheduleSemanticNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"plan.png"];
        self.tabBarItem.title = @"Wikiplan";
        self.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationBar.tintColor = kCOLOR_BACK;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    SemanticItemsViewController *controller = [[SemanticItemsViewController alloc] initWithNibName:@"SemanticItemsViewController" bundle:nil];
    [self pushViewController:controller animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
