//
//  CustomAnnotation.h
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/12/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import "ChargingStation.h"


@interface CustomAnnotation : MKPointAnnotation
@property ChargingStation *chargingStation;

@end
