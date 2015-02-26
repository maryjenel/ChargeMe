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
@property (weak, nonatomic) IBOutlet UILabel *totalEarned;
@property double totalEarnedAmount;

@end

@implementation OwnerPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Payment History";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.paymentsArray = [NSMutableArray new];

    // Find all the payments to this owner's stations
    PFQuery *query = [PFQuery queryWithClassName:@"Payments"];
    [query whereKey:@"stationOwner" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.paymentsArray = [objects mutableCopy];
        self.totalEarnedAmount = 0;
        for (PFObject *object in objects) {
            double value = [object[@"amountPaid"] doubleValue];
            self.totalEarnedAmount = self.totalEarnedAmount + value;
        }
        self.totalEarned.text = [NSString stringWithFormat:@"$%.2f", self.totalEarnedAmount];
        [self.tableView reloadData];
    }];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark TABLE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paymentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentsCell"];
    PFObject *payment = self.paymentsArray[indexPath.row];
    cell.textLabel.text = payment[@"shortDescription"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", payment[@"amountPaid"]];
    return cell;
}

@end
