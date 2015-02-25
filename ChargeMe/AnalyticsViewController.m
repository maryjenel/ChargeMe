//
//  AnalyticsViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/19/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "AnalyticsViewController.h"
#import "GraphView.h"

@interface AnalyticsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *analyticsView;

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
    PFObject *station = self.stationsArray[indexPath.row];
    [self retrievePaymentsWithSelectedStation:station andCompletion:^(NSMutableArray *payments)
    {
        // Add the graph view into the analytics view
        GraphView *graphView = [[GraphView alloc] initWithFrame:self.analyticsView.bounds];

        NSMutableArray *amountPaidArray = [NSMutableArray new];
        NSMutableArray *datesPaidArray = [NSMutableArray new];

        for (PFObject *payment in payments) {
            [amountPaidArray addObject:payment[@"amountPaid"]];

            // Format created date
            NSDate *createdDate = payment.createdAt;
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"dd/MM"];
            NSString *theDate = [dateFormatter stringFromDate:createdDate];

            [datesPaidArray addObject:theDate];
        }

        graphView.dataArray = [NSArray arrayWithArray:amountPaidArray];
        graphView.yAxisArray = [NSArray arrayWithArray:datesPaidArray];

        if (payments.count) {
            for(UIView *subview in [self.analyticsView subviews]) {
                [subview removeFromSuperview];
            }
            [self.analyticsView addSubview:graphView];
        }
    }];
}

- (void)retrievePaymentsWithSelectedStation:(PFObject *)station andCompletion:(void (^)(NSMutableArray *payments))complete
{
    // Find all the checkins that were made for the station selected on the table above
    PFQuery *query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"station" equalTo:station];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *paymentsMade = [NSMutableArray new];
        for (PFObject *checkInObject in objects) {

            // Find the payment details
            PFObject *payment = checkInObject[@"payment"];
            [payment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {

                if (paymentsMade.count < 7) {
                    // Get the amount paid
                    [paymentsMade addObject:payment];
                }

                // Return the payments once its on the last checkin object
                if (checkInObject == objects.lastObject) {
                    complete(paymentsMade);
                }

            }];
        }
    }];
}

@end
