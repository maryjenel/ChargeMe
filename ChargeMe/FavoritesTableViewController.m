//
//  FavoritesTableViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/18/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "SWRevealViewController.h"
#import "StationDetailViewController.h"
#import "ChargingStation.h"

@interface FavoritesTableViewController ()

@property NSMutableArray *stationsArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationsArray = [NSMutableArray new];

    self.menuButton.target = self.revealViewController;
    self.menuButton.action = @selector(revealToggle:);

    // Lets user use swipe to bring up menu
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.stationsArray removeAllObjects];
        if (!error) {
            for (PFObject *favoriteObject in objects) {
                PFObject *station = favoriteObject[@"station"];

                PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
                [query whereKey:@"objectId" equalTo:station.objectId];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                {
                    for (PFObject *stationObject in objects) {
                        [self.stationsArray addObject:stationObject];
                    }
                    [self.tableView reloadData];
                }];
            }
        }
        else
        {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errorAlertView show];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.stationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteStations" forIndexPath:indexPath];

    PFObject *stationInfo = self.stationsArray[indexPath.row];
    cell.textLabel.text = stationInfo[@"stationName"];
    cell.detailTextLabel.text = stationInfo[@"stationAddress"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FavoriteStationSegue"]) {
        PFObject *station = self.stationsArray[self.tableView.indexPathForSelectedRow.row];
        ChargingStation *chargingStation = [[ChargingStation alloc] initWithChargingStationPFObject:station];
        StationDetailViewController *sdvc = segue.destinationViewController;
        sdvc.chargingStation = chargingStation; 
    }
}

@end
