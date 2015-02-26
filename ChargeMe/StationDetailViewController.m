//
//  StationDetailViewController.m
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/12/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "StationDetailViewController.h"
#import "PayPalPaymentViewController.h"
#import "CustomAnnotation.h"
#import "Bookmark.h"
#import "LittleBitsObject.h"

#define contentType @"application/json"
#define accept @"application/vnd.littlebits.v2+json"

@interface StationDetailViewController () <PayPalPaymentDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property BOOL acceptCreditCards;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *hoursTextField;

@property NSDictionary *deviceInfo;

@property int hours;

@property NSArray *commentsArray;
@property NSMutableArray *messagesArray;
@property PFObject *stationObject;

@end

@implementation StationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagesArray = [NSMutableArray new];
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = self.chargingStation.stationName;
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];

    // setup map
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    CLLocationDegrees latitude = self.chargingStation.latitude;
    CLLocationDegrees longitude = self.chargingStation.longitude;

    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), MKCoordinateSpanMake(0.5, 0.5));
    [self.mapView setRegion:region animated:YES];

    [self loadMap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    // Get the same station from the parse store
    PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
    [query whereKey:@"nrel_id" equalTo:self.chargingStation.nrel_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if (objects.count) {
                // Check if the charging station is not one created by an owner in parse
                if ([self.chargingStation.nrel_id doubleValue] != 46333420) {
                    self.stationObject = [objects firstObject];
                }
                else
                {
                    // Find the station object with the object id
                    for (PFObject *stationObject in objects) {
                        if ([stationObject.objectId isEqualToString:self.chargingStation.object_id]) {
                            self.stationObject = stationObject;
                        }
                    }
                }
                [self getAllComments];
            }
            else
            {
                [ChargingStation saveAPIDataToParse:self.chargingStation.nrel_id andCompletion:^(PFObject *chargingStationObject) {
                    self.stationObject = chargingStationObject;
                    [self getAllComments];
                }];
            }
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}

- (void)loadMap
{
    CLLocationDegrees longitude;

    if (self.chargingStation.longitude < 0)
    {
        longitude = self.chargingStation.longitude;
    }
    else
    {
        longitude = -self.chargingStation.longitude;
    }

    CLLocationDegrees latitude = self.chargingStation.latitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    CustomAnnotation *annotation = [CustomAnnotation new];
    annotation.chargingStation = self.chargingStation;
    annotation.title = self.chargingStation.stationAddress;
    annotation.subtitle = self.chargingStation.stationName;
    annotation.coordinate = coordinate;

    [self.mapView addAnnotation:annotation];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Lets the mapView display the blue dot & circle animation
    if (annotation == mapView.userLocation) return nil;

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;

//    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}
- (IBAction)onButtonPressedDirectionsFromCurrentLocation:(id)sender
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.chargingStation.latitude, self.chargingStation.longitude);
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: coordinate addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = self.chargingStation.stationName;
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}
- (IBAction)onMessageButtonPressed:(id)sender {
//    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Send a Message" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField *textField)
//     {
//         nil;
//     }];
//    
//    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                                 {
//                                     UITextField *textField = alertcontroller.textFields.firstObject;
//                                     PFObject *myMessage = [PFObject objectWithClassName:@"Message"];
//                                     myMessage[@"content"] = textField.text;
//                                     myMessage[@"author"] = [PFUser currentUser];
////                                     myMessage[@"recipient"] = self.chargingStation.
//                                     [myMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                                         if (succeeded) {
//                                             [self getAllMessages];
//                                         }
//                                         else
//                                         {
//                                             NSLog(@"Message couldn't be saved: %@", error);
//                                         }
//                                     }];
//                                 }];
//    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    
//    [alertcontroller addAction:okayAction];
//    [alertcontroller addAction:cancelAction];
//    
//    [self presentViewController:alertcontroller animated:YES completion:^{
//        nil;
//    }];

}

- (IBAction)onAddToFavoritesButtonPressed:(id)sender {
    PFObject *user = [PFUser currentUser];
    PFObject *favorite = [PFObject objectWithClassName:@"Favorites"];
    favorite[@"station"] = self.stationObject;
    favorite[@"user"] = user;
    [favorite saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Favorited the station %@", self.stationObject[@"station_name"]);
    }];
}

- (IBAction)onAddCommentButtonPressed:(id)sender {
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Add A Comment!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         nil;
     }];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
         {
             UITextField *textField = alertcontroller.textFields.firstObject;
             PFObject *myComment = [PFObject objectWithClassName:@"Comment"];
             myComment[@"commentContext"] = textField.text;
             myComment[@"station"] = self.stationObject;
             myComment[@"user"] = [PFUser currentUser];
             [myComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded) {
                     [self getAllComments];
                 }
                 else
                 {
                     NSLog(@"Comment couldn't be saved: %@", error);
                 }
             }];
         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertcontroller addAction:okayAction];
    [alertcontroller addAction:cancelAction];
    
    [self presentViewController:alertcontroller animated:YES completion:^{
        nil;
    }];

}

#pragma mark Tableview Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *comment = self.commentsArray[indexPath.row];
    PFObject *user = comment[@"user"];
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", object[@"firstName"], object[@"lastName"]];
        [tableView reloadData];
    }];
    cell.textLabel.text = comment[@"commentContext"];
    
    return cell;
}

#pragma mark Helper Methods

- (void)getAllComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"station" equalTo:self.stationObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.commentsArray = objects;
         [self.tableView reloadData];
     }];
}
- (void)getAllMessages {
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"station" equalTo:self.stationObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.commentsArray = objects;
         [self.tableView reloadData];
     }];
}

#pragma mark PayPalPaymentDelegate methods

- (IBAction)onCheckInButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.hoursTextField.text isEqualToString:@""]) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Empty Fields" message:@"Please specify how long you'll be statying" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlertView show];
    }
    else {
        // Optional: include multiple items
        NSDecimalNumber *charge = [NSDecimalNumber decimalNumberWithString:@"39.99"];
        self.hours = [self.hoursTextField.text intValue];
        PayPalItem *item1 = [PayPalItem itemWithName:self.chargingStation.stationName
                                        withQuantity:self.hours
                                           withPrice:charge
                                        withCurrency:@"USD"
                                             withSku:@"CHS-00037"];
        NSArray *items = @[item1];
        NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];

        // Optional: include payment details
        NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0.00"];
        float taxValue = floorf(([charge floatValue] * (7.5/100) * 100) / 100);
        NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithFloat:taxValue];
        PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                                   withShipping:shipping
                                                                                        withTax:tax];

        NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];

        PayPalPayment *payment = [[PayPalPayment alloc] init];
        payment.amount = total;
        payment.currencyCode = @"USD";
        payment.shortDescription = self.chargingStation.stationName;
        payment.items = items;  // if not including multiple items, then leave payment.items as nil
        payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil

        if (!payment.processable) {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
        }

        // Update payPalConfig reaccepting credit cards.
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards;

        PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfig delegate:self];
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! %@", [completedPayment description]);

    // Payment was processed successfully; send to server for verification and fulfillment
    [self sendCompletedPaymentToServer:completedPayment];
}

// Turns the charging station on
- (void)turnChargingStationOnWithStation:(PFObject *)station {
    // Find Devices that belong to the station
    PFQuery *query = [PFQuery queryWithClassName:@"Devices"];
    [query whereKey:@"station" equalTo:station];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count) {
            PFObject *deviceObject = [objects firstObject];
            // Once successfully checked in, find the device information for little
            [LittleBitsObject retrieveDeviceInfoWithDeviceID:deviceObject[@"deviceID"] authorizationAccessToken:deviceObject[@"accessToken"] theContentType:contentType acceptFormat:accept withCompletionBlock:^(NSDictionary *deviceInfo) {
                self.deviceInfo = deviceInfo;

                // Set HTTP Body, turns on the module in 50,000 microsecond
                NSDictionary *dictionary = @{
                                             @"percent": @100,
                                             @"duration_ms": @10000
                                             };
                [LittleBitsObject turnDeviceOnWithDeviceInfo:self.deviceInfo authorizationAccessToken:deviceObject[@"accessToken"] theContentType:contentType acceptFormat:accept bodyDictionary:(NSDictionary *)dictionary];
            }];
        }
        else
        {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Device not Connected" message:@"The device could not be turned on because it was not found. Please contact owner." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errorAlertView show];
        }

    }];
}

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
    NSDictionary *response = completedPayment.confirmation[@"response"];

    // Check if the payment was approved
    if ([response[@"state"] isEqualToString:@"approved"]) {
        // Store the payment information onto parse with userinfo and station info
        PFObject *payment = [PFObject objectWithClassName:@"Payments"];
        payment[@"user"] = [PFUser currentUser];
        payment[@"amountPaid"] = completedPayment.amount;
        payment[@"currencyCode"] = completedPayment.currencyCode;
        payment[@"shortDescription"] = completedPayment.shortDescription;
        payment[@"station"] = self.stationObject;
        if (self.stationObject[@"owner"]) {
            payment[@"stationOwner"] = self.stationObject[@"owner"];
        }
        [payment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Saving Pament Info Successfull");

            // If payment is successful, checkin user
            if (succeeded) {
                PFObject *checkIn = [PFObject objectWithClassName:@"CheckIn"];
                checkIn[@"user"] = [PFUser currentUser];
                NSDate *currentDate = [NSDate date];
                checkIn[@"checkInDate"] = currentDate;

                NSTimeInterval secondsInSpecifiedHours = self.hours * 3600;
                checkIn[@"checkOutDate"] = [currentDate dateByAddingTimeInterval:secondsInSpecifiedHours];
                checkIn[@"payment"] = payment;
                checkIn[@"station"] = self.stationObject;
                if (self.stationObject[@"owner"]) {
                    checkIn[@"stationOwner"] = self.stationObject[@"owner"];
                }
                [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Check In Completed");

                        [self turnChargingStationOnWithStation:self.stationObject];
                    }
                }];
            }
        }];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Payment Failed" message:@"The payment you made failed. Plase check your paypal account" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlertView show];
    }
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
