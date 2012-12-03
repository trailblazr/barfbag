//
//  FahrplanViewController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 03.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "FahrplanViewController.h"
#import "EventsViewController.h"

@interface FahrplanViewController ()

@end

@implementation FahrplanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"plan.png"];
        self.tabBarItem.title = @"Fahrplan";
        self.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationBar.tintColor = kCOLOR_BACK;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    EventsViewController *eventsController = [[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
    [self pushViewController:eventsController animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
