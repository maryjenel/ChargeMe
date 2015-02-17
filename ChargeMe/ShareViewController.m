//
//  ShareViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/11/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "ShareViewController.h"
#import "SWRevealViewController.h"
#import "FindLocationOnMapViewController.h"
#import "ChargingStation.h"

@interface ShareViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *pickLocation;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property NSArray *plugTypes;
@property UIPickerView *pickerView;
@property MKPointAnnotation *chargingStationInfo;
@property (weak, nonatomic) IBOutlet UITextField *plugTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfPods;
@property (weak, nonatomic) IBOutlet UITextField *costTextField;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuButton.target = self.revealViewController;
    self.menuButton.action = @selector(revealToggle:);
    self.addressLabel.hidden = YES;

    self.pickerView = [UIPickerView new];
    self.pickerView.delegate = self;
    self.plugTypeTextField.inputView = self.pickerView;


    self.plugTypes = @[@"Wall Outlet (120v)", @"EV Plug (J1772) Level 1", @"EV Plug (J1772) Level 2", @"Quick Charge (CHAdeMO)", @"RV (Nema 14-50)", @"Tesla (Model S)", @"Tesla SuperCharger", @"Quick Charge (SAE Comb0)"];

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

// Retreieves the address from the modal view that appears
- (IBAction)unwindFromFindLocationOnMap:(UIStoryboardSegue *)segue
{
    FindLocationOnMapViewController *flomvc = segue.sourceViewController;
    self.chargingStationInfo = [flomvc newChargingStation];
    NSString *address = self.chargingStationInfo.subtitle;
    self.pickLocation.hidden = YES;
    self.addressLabel.hidden = NO;
    self.addressLabel.text = address;
}

- (IBAction)onSaveButtonTapped:(UIBarButtonItem *)sender
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.chargingStationInfo.coordinate.latitude longitude:self.chargingStationInfo.coordinate.longitude];
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error) {
             MKPlacemark *placemark = placemarks.firstObject;
             PFObject *user = [PFUser currentUser];
             PFObject *chargingStation = [PFObject objectWithClassName:@"Stations"];
             chargingStation[@"stationName"] = placemark.name;
             chargingStation[@"latitude"] = [NSString stringWithFormat:@"%f", self.chargingStationInfo.coordinate.latitude];
             chargingStation[@"longitude"] = [NSString stringWithFormat:@"%f", self.chargingStationInfo.coordinate.longitude];
             chargingStation[@"streetAddress"] = self.chargingStationInfo.subtitle;
             chargingStation[@"zipCode"] = placemark.addressDictionary[@"ZIP"];
             chargingStation[@"state"] = placemark.addressDictionary[@"State"];
             chargingStation[@"city"] = placemark.addressDictionary[@"City"];
             chargingStation[@"country"] = placemark.addressDictionary[@"Country"];
             chargingStation[@"stationPhoneNumber"] = user[@"phoneNumber"];
             chargingStation[@"groups_with_access_code"] = @"Private";
             chargingStation[@"owner"] = user;
             chargingStation[@"cost"] = self.costTextField.text;
             // Enumerate the plugtypes and find the one that was entered
             for (NSString *plugType in self.plugTypes) {
                 // Check if the plug type that was entered exists
                 if ([plugType isEqualToString:self.plugTypeTextField.text]) {
                     // Filter the level of the plug type
                     chargingStation[@"plugType"] = plugType;
                     if ([plugType isEqualToString:@"Wall Outlet (120v)"] | [plugType isEqualToString:@"EV Plug (J1772) Level 1"])
                     {
                         chargingStation[@"ev_level1_evse_num"] = self.numberOfPods.text;
                     }
                     else if ([plugType isEqualToString:@"RV (Nema 14-50)"] | [plugType isEqualToString:@"Quick Charge (SAE Comb0)"])
                     {
                         chargingStation[@"ev_level2_evse_num"] = self.numberOfPods.text;
                     }
                     else {
                         chargingStation[@"ev_dc_fast_num"] = self.numberOfPods.text;
                         chargingStation[@"ev_other_evse"] = self.numberOfPods.text;
                     }
                 }
             }
             [chargingStation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 user[@"userType"] = @"StationOwner";
                 [user saveInBackground];
             }];
         }
     }];

}

#pragma mark Type of Charge Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.plugTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.plugTypes[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.plugTypeTextField.text = self.plugTypes[row];
    [self.plugTypeTextField resignFirstResponder];
}

@end
