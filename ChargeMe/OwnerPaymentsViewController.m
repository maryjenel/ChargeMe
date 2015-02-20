//
//  OwnerPaymentsViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/19/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "OwnerPaymentsViewController.h"

@interface OwnerPaymentsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *paymentsArray;

@end

@implementation OwnerPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.paymentsArray = [NSMutableArray new];

    // Find all the payments to this owner's stations
    PFQuery *query = [PFQuery queryWithClassName:@"Payments"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.paymentsArray = [objects mutableCopy];
        [self.tableView reloadData];
    }];
}

#pragma mark TABLE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    return cell;
}

@end
