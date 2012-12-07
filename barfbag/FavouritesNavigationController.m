//
//  FavouritesNavigationController.m
//  barfbag
//
//  Created by Lincoln Six Echo on 07.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "FavouritesNavigationController.h"
#import "FavouritesViewController.h"

@implementation FavouritesNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.image = [UIImage imageNamed:@"favourites.png"];
        self.tabBarItem.title = LOC( @"Favoriten" );
        self.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationBar.tintColor = kCOLOR_BACK;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    FavouritesViewController *controller = [[FavouritesViewController alloc] initWithNibName:@"FavouritesViewController" bundle:nil];
    [self pushViewController:controller animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC( @"Zurück" ) style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
