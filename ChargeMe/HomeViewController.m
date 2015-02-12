//
//  ViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/9/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import <ParseUI/ParseUI.h>
#import "Crittercism.h"
#import "SignUpViewController.h"
#define kApiKeyNrel "sQUMD8G5IKWZtOOQeYatEHBFJR6YEf8DFRj9mJhe"


@interface HomeViewController ()<PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate, MKMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *stationsArray;
@property NSMutableArray *chargeStationsArray;
@property NSMutableArray *annotationsArray;
@property MKPointAnnotation *reusablePoint;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chargeStationsArray = [NSMutableArray new];
    self.searchBar.delegate = self;
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1.json?api_key=%s&fuel_type=ELEC&state=CA&limit=10", kApiKeyNrel];
    [self getAllChargingStations:jsonAddress];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;

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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self findStationsNearby:searchBar.text];
    [self.searchBar resignFirstResponder];
}

-(void)findStationsNearby:(NSString *)searchText

{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchText;
    request.region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSArray *mapItems = response.mapItems;

        //        NSMutableArray *temporaryArray = [NSMutableArray new];

        for (MKMapItem *mapItem in mapItems)
        {
            MKCoordinateRegion region = MKCoordinateRegionMake(mapItem.placemark.location.coordinate, MKCoordinateSpanMake(0.05, 0.05));
            self.mapView.region = region;
        }
        //        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"metersAway" ascending:true];
        //        NSArray *sortedArray = [temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        //        self.pizzeriasArray = [NSMutableArray arrayWithArray:sortedArray];
        //        [self.tableView reloadData];
        //        [self createSourceAndDestination];
        
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Crittercism beginTransaction:@"login"];
    if (![PFUser currentUser]) {
        [Crittercism beginTransaction:@"my_transaction"];
        LoginViewController *loginViewController = [[LoginViewController alloc]init];
        [loginViewController setDelegate:self];
        SignUpViewController *signUpViewController = [[SignUpViewController alloc]init];
        [signUpViewController setDelegate:self];
      //  [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        [loginViewController setSignUpController:signUpViewController];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations.lastObject;
    if (self.currentLocation != nil) {
        if (self.currentLocation.verticalAccuracy < 300 && self.currentLocation.horizontalAccuracy < 300) {
            [self.locationManager stopUpdatingLocation];
            NSLog(@"Current Location Found");
        }
    }
}

-(void)pinEachChargingStation//how to place pins
{
    for (ChargingStation *chargingStation in self.chargeStationsArray)
    {
        CLLocationDegrees longitude;

        if (chargingStation.longitude < 0)
        {
            longitude = chargingStation.longitude;
        }
        else
        {
            longitude = -chargingStation.longitude;
        }

        CLLocationDegrees latitude = chargingStation.latitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

        CustomAnnotation *annotation = [CustomAnnotation new];
        annotation.chargingStation = chargingStation;
        annotation.title = chargingStation.stationAddress;
        annotation.subtitle = chargingStation.stationName;
        annotation.coordinate = coordinate;

        [self.annotationsArray addObject:annotation];
        [self.mapView addAnnotation:annotation];
    }
    //    [self.tableView reloadData];
    [self.mapView showAnnotations:self.annotationsArray animated:YES];
}

- (void)getAllChargingStations:(NSString *)jsonAddress
{
    NSURL *url = [NSURL URLWithString:jsonAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.stationsArray = [resultsDictionary objectForKey:@"fuel_stations"];

         for (NSDictionary *chargingStationDictionary in self.stationsArray)
         {
             ChargingStation *chargingStation = [ChargingStation new];
             chargingStation.latitude = [chargingStationDictionary[@"latitude"] doubleValue];
             chargingStation.longitude = [chargingStationDictionary[@"longitude"] doubleValue];
             chargingStation.stationName = chargingStationDictionary[@"station_name"];
             chargingStation.stationAddress = chargingStationDictionary[@"street_address"];
             chargingStation.stationPhone = chargingStationDictionary[@"station_phone"];
             chargingStation.city = chargingStationDictionary[@"city"];
             chargingStation.state = chargingStationDictionary[@"state"];
             chargingStation.level1Charge = chargingStationDictionary[@"ev_level1_evse_num"];
             chargingStation.level2Charge = chargingStationDictionary[@"ev_level2_evse_num"];
             chargingStation.groupAccessCode = chargingStationDictionary[@"groups_with_access_code"];
             chargingStation.otherCharge = chargingStationDictionary[@"ev_other_evse"];

             chargingStation.location = [resultsDictionary objectForKey:@""];

             [self.chargeStationsArray addObject:chargingStation];
         }
         [self pinEachChargingStation];
     }];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    //    pin.image = [UIImage imageNamed:@"mobilemakers"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //    CustomAnnotation *customAnnotation = view.annotation;
    //    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    //    request.naturalLanguageQuery = @"chargingStations";
    //    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.09, 0.09));
}



-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES;
    }
    [[[UIAlertView alloc]initWithTitle:@"Missing Information!" message:@"Make sure you fill out all the information, please!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    return NO;
}

@end
