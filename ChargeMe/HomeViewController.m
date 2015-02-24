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
#import "StationDetailViewController.h"
#import "LoginViewController.h"
#import <SpeechKit/SpeechKit.h>
#import "AppDelegate.h"

// API Key for NREL
#define kApiKeyNrel "sQUMD8G5IKWZtOOQeYatEHBFJR6YEf8DFRj9mJhe"


@interface HomeViewController ()<PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate, MKMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate, SpeechKitDelegate,SKRecognizerDelegate, SKVocalizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property NSArray *stationsArray;
@property NSMutableArray *chargeStationsArray;
@property NSMutableArray *annotationsArray;
@property MKPointAnnotation *reusablePoint;
@property NSMutableArray *publicChargeStationsArray;
@property NSMutableArray *privateChargeStationsArray;
@property SKRecognizer *voiceSearch;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property SKVocalizer *vocalizer;
@property BOOL isSpeaking;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

const unsigned char SpeechKitApplicationKey[] = {0xf8, 0x4c, 0xee, 0xcf, 0x34, 0x12, 0xc5, 0x3d, 0xff, 0x44, 0x8f, 0x84, 0x43, 0x10, 0x08, 0xd8, 0x2c, 0xb9, 0x42, 0x19, 0x78, 0x39, 0x4b, 0x4b, 0xa1, 0x4e, 0x24, 0xcf, 0x7b, 0xf9, 0x02, 0x73, 0x45, 0xf0, 0x43, 0x79, 0x02, 0x08, 0xb6, 0x01, 0x4c, 0x45, 0x86, 0x8f, 0x56, 0x8e, 0x68, 0x82, 0x47, 0xaa, 0x9b, 0xbf, 0xe3, 0xe6, 0x0b, 0x84, 0x34, 0x2f, 0x54, 0xb0, 0x28, 0x56, 0x23, 0x6d};

@implementation HomeViewController
- (IBAction)onbuttonP:(UIButton *)sender
{
    [ChargingStation addAPIDatatoParse];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![PFUser currentUser])
    {
        LoginViewController *loginViewController = [[LoginViewController alloc]init];
        [loginViewController setDelegate:self];

        SignUpViewController *signUpViewController = [[SignUpViewController alloc]init];
        [signUpViewController setDelegate:self];

        [loginViewController setSignUpController:signUpViewController];

        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    self.chargeStationsArray = [NSMutableArray new];
    self.publicChargeStationsArray = [NSMutableArray new];
    self.privateChargeStationsArray = [NSMutableArray new];

    //change background color to black & nav barr
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    self.searchBar.delegate = self;
    NSString *jsonAddress = [NSString stringWithFormat:@"https://developer.nrel.gov/api/alt-fuel-stations/v1.json?api_key=%s&fuel_type=ELEC&state=CA&limit=100", kApiKeyNrel];
    [self getAllChargingStations:jsonAddress];

    // Initialize the location manager and upate the current user
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;

    //updates current location after the view loads app always has users current location
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.appDelegate updateCurrentLocation];
    [self.appDelegate setupSpeechKitConnection];

    self.searchBar.returnKeyType = UIReturnKeySearch;
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle: )];
        [self.view addGestureRecognizer:self .revealViewController.panGestureRecognizer];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self findStationsNearby:searchBar.text];
    [self.searchBar resignFirstResponder];
}

/**
 *  Find all charging stations with searched text
 *
 *  @param searchText A string to search
 */
-(void)findStationsNearby:(NSString *)searchText

{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchText;
    request.region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
        {

        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        MKCoordinateRegion region = MKCoordinateRegionMake(mapItem.placemark.location.coordinate, MKCoordinateSpanMake(0.05, 0.05));
        self.mapView.region = region;
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location is Disabled"
                                                        message:@"Enable it in settings and try again"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }


}

// Navigate to current user location when location button is tapped
- (IBAction)onCurrentLocationButtonTapped:(UIButton *)sender
{
    MKCoordinateRegion region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(1, 1));
    [self.mapView setRegion:region animated:YES];
}

/**
 *  Filter By Public Private and Home
 *
 *  @param sender Chosen item from the Segmented control
 */

- (IBAction)onSegmentedControlButtonPressed:(UISegmentedControl *)sender
{
    long selectedLong = sender.selectedSegmentIndex;
    if (selectedLong == 0)
        
    {
        self.publicChargeStationsArray = [self filterForGroups:selectedLong];
        [self pinEachChargingStation:selectedLong];
    }
    if (selectedLong == 1)
        
    {
        self.privateChargeStationsArray = [self filterForGroups:selectedLong];
        [self pinEachChargingStation:selectedLong];
    }
    if (sender.selectedSegmentIndex == 2)
    {
        [self filterForGroups:selectedLong];
        [self pinEachChargingStation:selectedLong];
    }
}

//User filter for level of Charger
- (NSMutableArray *)filterForLevelOfCharger:(long)value

{
    NSMutableArray *level1ChargeArray = [NSMutableArray new];
    NSMutableArray *level2ChargeArray = [NSMutableArray new];
    NSMutableArray *level3ChargeArray = [NSMutableArray new];
    
    if (value == 0) {
        for (ChargingStation *level1ChargerStation in self.chargeStationsArray)
        {
            if ([level1ChargerStation.connectorType hasPrefix:@"NEMA520"])
            {
                [level1ChargeArray addObject:level1ChargerStation];
            }
        }
        if (value == 1)
        {
            for (ChargingStation *level2ChargerStation in self.chargeStationsArray)
            {
                if ([level2ChargerStation.connectorType hasPrefix:@"J1772"])
                {
                    [level2ChargeArray addObject:level2ChargerStation];
                }
            }
            if (value ==2)
            {
                for (ChargingStation *level3ChargerStation in self.chargeStationsArray)
                {
                    if ([level3ChargerStation.connectorType hasPrefix:@"CHADEMO"] |[level3ChargerStation.connectorType hasPrefix:@"J1772COMBO"]| [level3ChargerStation.connectorType hasPrefix:@"TESLA"])
                    {
                        [level3ChargeArray addObject:level3ChargerStation];
                    }
                }
            }
        }
    }
    return self.chargeStationsArray;
}

//filtering public/private + all for map
-(NSMutableArray *)filterForGroups:(long)value
{
    NSMutableArray *publicArray = [NSMutableArray new];
    NSMutableArray *privateArray = [NSMutableArray new];
    if (value == 0) {
        for (ChargingStation *station in self.chargeStationsArray)
        {
            if([station.groupAccessCode hasPrefix:@"Public"])
            {
                [publicArray addObject:station];
            }
        }
        return publicArray;
    }
    else if (value == 1) {
        for (ChargingStation *station in self.chargeStationsArray)
        {
            if([station.groupAccessCode hasPrefix:@"Private"])
            {
                [privateArray addObject:station];
            }
        }
        return privateArray;
    }
    return self.chargeStationsArray;
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
            MKCoordinateRegion region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.5, 0.5));
            self.mapView.region = region;
        }
    }
}


//pin charging stations by first removing annotations and then adds them on map
-(void)pinEachChargingStation: (long)filterType
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *temporaryArray = [NSMutableArray new];
    switch (filterType) {
        case 0:
            temporaryArray = self.publicChargeStationsArray;
            break;
            
        case 1:
            temporaryArray = self.privateChargeStationsArray;
            break;
            
        default:
            temporaryArray = self.chargeStationsArray;
            break;
    }
    for (ChargingStation *chargingStation in temporaryArray)
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
        annotation.filterType = filterType;

        [self.annotationsArray addObject:annotation];
        [self.mapView addAnnotation:annotation];
    }

    [self.mapView showAnnotations:self.annotationsArray animated:YES];
}


//getting charging station info from government energy json
- (void)getAllChargingStations:(NSString *)jsonAddress
{
    NSURL *url = [NSURL URLWithString:jsonAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data) {
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
                 chargingStation.evDCFastNum = chargingStationDictionary[@"ev_dc_fast_num"];
                 chargingStation.evOtherEvse = chargingStationDictionary[@"ev_other_evse"];
                 chargingStation.groupAccessCode = chargingStationDictionary[@"groups_with_access_code"];
                 chargingStation.ownerTypeCode = chargingStationDictionary[@"owner_type_code"];
                 chargingStation.otherCharge = chargingStationDictionary[@"ev_other_evse"];
                 chargingStation.zipCode = [chargingStationDictionary[@"zip"] doubleValue];
                 chargingStation.nrel_id = chargingStationDictionary[@"id"];

                 [self.chargeStationsArray addObject:chargingStation];
             }

             [self pinEachChargingStation:2];
         }
         else
         {
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:[NSString stringWithFormat:@"%@", [connectionError localizedDescription]] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
             [errorAlertView show];
         }

     }];

    // Load all stations added by chargeme user
    PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
    [query whereKey:@"nrel_id" equalTo:[NSNumber numberWithInt:46333420]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error) {
             for (PFObject *stationObject in objects) {
                 ChargingStation *chargingStation = [[ChargingStation alloc] initWithChargingStationPFObject:stationObject];
                 [self.chargeStationsArray addObject:chargingStation];
             }
             [self pinEachChargingStation:2];
         }
     }];
}

//Pin annotation color choice by filter
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Lets the mapView display the blue dot & circle animation
    if (annotation == mapView.userLocation) return nil;

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    CustomAnnotation *customAnnotation = annotation;
    switch (customAnnotation.filterType) {
        case 0:
            pin.pinColor = MKPinAnnotationColorGreen;
            break;
        case 1:
            pin.pinColor = MKPinAnnotationColorPurple;
            break;

        default:
            pin.pinColor = MKPinAnnotationColorRed;
            break;
    }
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

// Segue to station detail view controller when callout accessory button is tapped
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"callOutSegue" sender:view.annotation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"callOutSegue"]) {
        CustomAnnotation *annotation = (CustomAnnotation *)sender;
        StationDetailViewController *sdvc = segue.destinationViewController;
        sdvc.chargingStation = annotation.chargingStation;
        sdvc.currentLocation = self.currentLocation;
    }
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


#pragma mark VOICE ACTIVATION

-(IBAction)onRecordButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.isSelected;

    // This will initialize a new speech recognizer instance
    if (sender.isSelected) {
        self.voiceSearch = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                    detection:SKShortEndOfSpeechDetection
                                                     language:@"en_US"
                                                     delegate:self];
    }

    // This will stop existing speech recognizer processes
    else {
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            [self.voiceSearch cancel];
        }
    }
    if (self.isSpeaking) {
        [self.vocalizer cancel];
        self.isSpeaking = false;
    }
}

-(void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    self.title = @"Listening..."; // title changes to listening.. when listening..
}

-(void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    self.title = @"Done Listening...";//title changes to done listening when done listening...
    [self findStationsNearby:self.searchBar.text];
}
-(void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    long numOfResults = [results.results count];
    if (numOfResults > 0)
    {
        //update the text of text field with best result from SpeechKit
        self.searchBar.text = [results firstResult];
    }
    self.recordButton.selected = !self.recordButton.isSelected;

    if (self.voiceSearch)
    {
        [self.voiceSearch cancel];
    }
}

-(void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    self.recordButton.selected = NO;
    self.title = @"Connection error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                   message:[error
                                                            localizedDescription]
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];

    [alert show];
}

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text {
    self.isSpeaking = YES;
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
    if (error !=nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        if (self.isSpeaking) {
            [self.vocalizer cancel];
        }
    }
    
    self.isSpeaking = false;
}
@end
