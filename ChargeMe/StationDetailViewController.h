//
//  StationDetailViewController.h
//  ChargeMe
//
//  Created by Tewodros Wondimu on 2/12/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PayPalMobile.h"
#import "ChargingStation.h"

@interface StationDetailViewController : UIViewController

@property ChargingStation *chargingStation;
@property CLLocation *currentLocation;

@end
