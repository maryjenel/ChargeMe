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
@property (weak, nonatomic) IBOutlet UILabel *customerName;
@property (weak, nonatomic) IBOutlet UILabel *hoursSince;

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

    // Changes the background color of the cell when highlighted
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Charging Stations";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the user for the selected station with the owner
    PFObject *station = self.stationsArray[indexPath.row];

    PFQuery *checkInUserQuery = [PFQuery queryWithClassName:@"CheckIn"];
    [checkInUserQuery whereKey:@"stationOwner" equalTo:[PFUser currentUser]];
    [checkInUserQuery whereKey:@"station" equalTo:station];
    [checkInUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count) {
                PFObject *checkInObject = [objects firstObject];
                NSLog(@"These are the objects: %@", checkInObject);

                // Check if the person is currently checked in
                BOOL isCurrentUser = [self date:[NSDate date] isBetweenDate:checkInObject[@"checkInDate"] andDate:checkInObject[@"checkOutDate"]];

                // If current user, fetch user details
                if (isCurrentUser) {
                    PFUser *user = checkInObject[@"user"];
                    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        self.customerName.text = [NSString stringWithFormat:@"%@ %@", object[@"firstName"], object[@"lastName"]];

                        double sinceCheckIn = [checkInObject[@"checkOutDate"] timeIntervalSinceDate:[NSDate date]] / 3600;
                        self.hoursSince.text = [NSString stringWithFormat:@"%.2f hours since check in", sinceCheckIn];
                    }];
                }
            }
        }
    }];
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([date compare:endDate] == NSOrderedDescending)
        return NO;

    return YES;
}

@end
