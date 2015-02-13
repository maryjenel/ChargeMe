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

@interface StationDetailViewController () <PayPalPaymentDelegate, MKMapViewDelegate>

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property BOOL acceptCreditCards;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation StationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = self.chargingStation.stationName;
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];

    //
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self loadMap];
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

#pragma mark PayPalPaymentDelegate methods

- (IBAction)onCheckInButtonPressed:(UIBarButtonItem *)sender
{
    // Note: For purposes of illustration, this example shows a payment that includes
    //       both payment details (subtotal, shipping, tax) and multiple items.
    //       You would only specify these if appropriate to your situation.
    //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
    //       and simply set payment.amount to your total charge.

    // Optional: include multiple items
    PayPalItem *item1 = [PayPalItem itemWithName:@"Los Santos Charging Station"
                                    withQuantity:4
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"39.99"]
                                    withCurrency:@"USD"
                                         withSku:@"CHS-00037"];
    PayPalItem *item2 = [PayPalItem itemWithName:@"Las Vegas Charging Station"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"0.00"]
                                    withCurrency:@"USD"
                                         withSku:@"CHS-00066"];
    NSArray *items = @[item1, item2];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];

    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"5.99"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"2.50"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];

    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];

    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Charging Station Costs";
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

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! %@", [completedPayment description]);

    //    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
