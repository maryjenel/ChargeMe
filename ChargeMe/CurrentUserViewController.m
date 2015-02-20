//
//  CurrentUserViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/19/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "CurrentUserViewController.h"

@interface CurrentUserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *stationsArray;

@end

@implementation CurrentUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.stationsArray = [NSMutableArray new];
    
    // Find all the station this owner has added
    PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.stationsArray = [objects mutableCopy];
        [self.tableView reloadData];
    }];
}

#pragma mark TABLE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display the stations that are owned by this user
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargingStationsCell"];
    PFObject *station = self.stationsArray[indexPath.row];
    cell.textLabel.text = station[@"stationName"];
    return cell;
}

@end
