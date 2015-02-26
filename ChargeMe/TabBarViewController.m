//
//  TabBarViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/17/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "TabBarViewController.h"
#import "SWRevealViewController.h"
#import "ShareViewController.h"

@interface TabBarViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property NSArray *titleArray;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleArray = [[NSArray alloc] initWithObjects:@"Current User", @"Analytics", @"Payment History", nil];

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

    // Set the navigation title to Current User on first load
    self.navigationItem.title = self.titleArray[0];
}

// Changes the titles of the tab bar navigation item title on item selected
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Current User"]) {
        self.navigationItem.title = self.titleArray[0];
    }
    else if ([item.title isEqualToString:@"Analytics"])
    {
        self.navigationItem.title = self.titleArray[1];
    }
    else
    {
        self.navigationItem.title = self.titleArray[2];
    }
}

- (IBAction)onAddChargerButtonTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"AddMoreChargersSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ShareViewController *svc = segue.destinationViewController;
    svc.menuHidden = YES;
}

@end
