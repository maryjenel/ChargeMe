//
//  TabBarViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/17/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "TabBarViewController.h"
#import "SWRevealViewController.h"

@interface TabBarViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {

        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
