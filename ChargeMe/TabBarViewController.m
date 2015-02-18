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
