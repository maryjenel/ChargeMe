//
//  AnalyticsViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/19/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *stationsArray;

@end

@implementation AnalyticsViewController

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find all the checkins that were made for the station selected on the table above
    PFQuery *query = [PFQuery queryWithClassName:@"CheckIn"];
    PFObject *station = self.stationsArray[indexPath.row];
    [query whereKey:@"station" equalTo:station];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *checkInObject in objects) {
            PFObject *user = checkInObject[@"user"];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
                PFObject *payment = checkInObject[@"payment"];
                [payment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"%@ paid: %@", fullName, payment[@"amountPaid"]);
                }];
            }];
        }
    }];
}

@end
